# Regional Health Platform — Rehosting Capacity Lab

Working repo for Assignment 2 (see `ASSIGNMENT.md`).

## Status

- **Phase 1** (Member 1, PR #1 `feature/service-module-infra`, open): LocalStack
  bootstrap, `terraform/modules/service` (EC2 + nginx + ALB), the root
  Terraform scaffold (`terraform/main.tf` etc., applied with `tflocal`).
- **Phase 2** (Member 2, this branch): `terraform/modules/data` (Aiven MySQL +
  LocalStack Secrets Manager), `api/` secret resolution + DB pool + health
  endpoints, migrations. Wired into the Phase 1 root (`module "data"` in
  `terraform/main.tf`) per the integration point Phase 1 left commented out.
- **Phase 3** (Member 3): CI/CD, security scans, observability, k6 — not
  started.

**Deviation from `ASSIGNMENT.md`:** `terraform/modules/data` provisions a
real **Aiven for MySQL** service instead of LocalStack's RDS emulation —
confirmed as the group's intent by Phase 1's own comment in `terraform/main.tf`
before this module existed. Secrets Manager stays on LocalStack; only the
database backend is real. Documented in `FIDELITY.md`. This means
`evidence/01-iac` and `evidence/02-data` are evidence against a real cloud
API for the DB, not an emulator — `terraform destroy` has real (if
Hobby-tier-free) consequences and isn't something to rerun casually.

| Path | What it is | Owner |
|---|---|---|
| `terraform/modules/data/` | Aiven MySQL service + LocalStack Secrets Manager secret (envelope: engine/username/password/host/port/dbname). | Phase 2 |
| `terraform/main.tf` | Root composing `module "data"` + `module "service"`, applied with `tflocal`. | Phase 1 root, Phase 2 wiring |
| `terraform/envs/dev/` | Standalone root applying only `modules/data` — for C2/C3 evidence independent of `app_ami_id`/the full stack. | Phase 2 |
| `api/secrets.js` | Resolves DB creds from Secrets Manager at boot via `AWS_ENDPOINT_URL` (unset on real AWS — no `isLocalStack` branch). | Phase 2 |
| `api/database.js` | mysql2 pool + `/readyz` check (DB unreachable, pool saturated, or secret unresolved → not ready). | Phase 2 |
| `api/server.js` | Express app: `/healthz`, `/readyz`, `/debug/secret-source`. | Phase 2 |
| `api/migrations/` | `001_init.sql` (placeholder `patients` schema — see caveat below), `migrate.js`, `seed.js` (row count via `PATIENT_COUNT`, default 10,000). | Phase 2 |
| `scripts/demo-readyz-degrade.sh` | Rotates the secret to a wrong password, restarts the app, captures the `/readyz` 503→200 flip for `evidence/04-health/readyz-degraded.txt`. | Phase 2 |

**Schema caveat:** there is no A1 app/schema to migrate from, so
`api/migrations/001_init.sql` is a minimal placeholder (`patients` table)
built to prove the pipe end-to-end — not the graded app's real schema.
Reconcile it once the actual service exists (Phase 4).

## Right-sizing (Aiven side)

`aiven_plan` (in both `terraform/variables.tf` and
`terraform/modules/data/variables.tf`) has **no default** on purpose — plan
slugs and pricing change over time. Look yours up before applying:

```
avn service plan-list --project <aiven_project> mysql
```

## Running it locally

```bash
# Full stack (needs app_ami_id from Phase 1's CI + AIVEN_TOKEN + LocalStack via tflocal)
cd terraform
tflocal init -backend-config=backend.hcl   # backend.hcl per person, gitignored
tflocal apply -var="aiven_project=..." -var="aiven_plan=..." -var="app_ami_id=..."

# modules/data alone, no app_ami_id needed (Phase 2 evidence)
cd terraform/envs/dev
cp terraform.tfvars.example terraform.tfvars   # fill in project + plan
terraform init && terraform apply

# App
cd ../../../api
cp .env.example .env   # fill in DB_SECRET_ARN from the terraform output, or use MYSQL_* fallback
npm install
npm run migrate
npm run seed
npm start
curl localhost:3000/healthz
curl localhost:3000/readyz
curl localhost:3000/debug/secret-source
```

## What's NOT here yet

The golden CI workflow, `Makefile`, observability wiring (Phase 3), and k6
incident replay / evidence collection (Phase 4, all members) haven't
started.

## First moves (original starter-pack notes)

1. Read `ASSIGNMENT.md` end to end.
2. Sort your **free Hobby** LocalStack token and a **Linux Codespace** (see
   the Environment section — don't fight a Mac).
