#!/usr/bin/env bash
# C4 evidence generator: break the secret, show /readyz flip to 503 (and that
# nginx would pull the upstream), fix it, show recovery.
#
# Run against a live LocalStack + Secrets Manager + running app. Redirect
# stdout to evidence/04-health/readyz-degraded.txt:
#   ./scripts/demo-readyz-degrade.sh | tee evidence/04-health/readyz-degraded.txt
#
# Requires: aws cli, curl, jq. App must be started with DB_SECRET_ARN set
# (not the MYSQL_* fallback) and restarted between steps so it re-reads the
# secret at boot, matching the "caches in memory" design in secrets.js.

set -euo pipefail

: "${AWS_ENDPOINT_URL:?set AWS_ENDPOINT_URL, e.g. http://localhost:4566}"
: "${DB_SECRET_ARN:?set DB_SECRET_ARN to the secret from terraform output secret_arn}"
: "${APP_URL:=http://localhost:3000}"
: "${RESTART_CMD:?set RESTART_CMD to whatever restarts the app (e.g. \"docker restart app\" or \"pm2 restart app\")}"

aws_cli() { aws --endpoint-url "$AWS_ENDPOINT_URL" "$@"; }

echo "=== 1. current secret (redacted) ==="
aws_cli secretsmanager get-secret-value --secret-id "$DB_SECRET_ARN" \
  | jq '.SecretString | fromjson | .password = "[redacted]"'

ORIGINAL=$(aws_cli secretsmanager get-secret-value --secret-id "$DB_SECRET_ARN" --query SecretString --output text)

echo
echo "=== 2. rotating to a wrong password ==="
BROKEN=$(echo "$ORIGINAL" | jq '.password = "deliberately-wrong-password"')
aws_cli secretsmanager put-secret-value --secret-id "$DB_SECRET_ARN" --secret-string "$BROKEN" >/dev/null
echo "secret rotated, restarting app: $RESTART_CMD"
eval "$RESTART_CMD"
sleep 3

echo
echo "=== 3. /readyz with broken secret (expect 503) ==="
curl -sS -w '\nHTTP %{http_code}\n' "$APP_URL/readyz"

echo
echo "=== 4. restoring original secret ==="
aws_cli secretsmanager put-secret-value --secret-id "$DB_SECRET_ARN" --secret-string "$ORIGINAL" >/dev/null
echo "secret restored, restarting app: $RESTART_CMD"
eval "$RESTART_CMD"
sleep 3

echo
echo "=== 5. /readyz recovered (expect 200) ==="
curl -sS -w '\nHTTP %{http_code}\n' "$APP_URL/readyz"
