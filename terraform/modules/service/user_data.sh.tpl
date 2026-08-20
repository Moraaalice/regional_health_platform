#!/usr/bin/env bash
set -euo pipefail

# Infra's job stops here: hand off *where* the DB and the secret live.
# The app resolves the secret *value* itself via GetSecretValue at boot
# (api/secrets.js) — this file never carries a credential, only its address.
cat > /etc/regional-health.env <<EOF
DB_SECRET_ARN=${secret_arn}
DB_HOST=${db_endpoint}
DB_PORT=${db_port}
APP_PORT=${app_port}
AWS_ENDPOINT_URL=http://localhost.localstack.cloud:4566
EOF

# TODO (Phase 2/3): start nginx (upstream health check against /readyz) and
# the app container here, sourcing /etc/regional-health.env. nginx must stop
# routing to this instance the moment /readyz returns non-200 (C4).
