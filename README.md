# Rehosting Capacity Lab

Working repo for Assignment 2 (see `ASSIGNMENT.md`). Originally a starter
pack meant to be copied into an existing Assignment-1 repo — there is no A1
repo here, so this directory is being used directly as the working repo.

## Phase 2 (this repo, so far) — Member 2

Aiven MySQL, Secrets Manager integration, migrations, health endpoints.
Phase 1 (LocalStack setup, `modules/service`, root composition) and Phase 3
(CI/CD, security scans, observability, k6) are separate group phases, not
included here.

**Deviation from `ASSIGNMENT.md`:** `terraform/modules/data` provisions a
real **Aiven for MySQL** service instead of LocalStack's RDS emulation.
Secrets Manager stays on LocalStack. This is a deliberate group choice —
documented in `FIDELITY.md` — not a LocalStack fidelity gap, and it means
`evidence/01-iac` and `evidence/02-data` are evidence against a real cloud
API, not an emulator.

| Path | What it is |
|---|---|
| `terraform/modules/data/` | Aiven MySQL service + LocalStack Secrets Manager secret (envelope: engine/username/password/host/port/dbname). |
| `terraform/envs/dev/` | Standalone root that applies only `modules/data`, for C2/C3 evidence before `modules/service` exists. |
| `api/secrets.js` | Resolves DB creds from Secrets Manager at boot via `AWS_ENDPOINT_URL` (unset on real AWS — no `isLocalStack` branch). |
| `api/database.js` | mysql2 pool + `/readyz` check (DB unreachable, pool saturated, or secret unresolved → not ready). |
| `api/server.js` | Express app: `/healthz`, `/readyz`, `/debug/secret-source`. |
| `api/migrations/` | `001_init.sql` (placeholder `patients` schema — see caveat below), `migrate.js`, `seed.js` (row count via `PATIENT_COUNT`, default 10,000). |
| `scripts/demo-readyz-degrade.sh` | Rotates the secret to a wrong password, restarts the app, captures the `/readyz` 503→200 flip for `evidence/04-health/readyz-degraded.txt`. |

**Schema caveat:** there is no A1 app/schema to migrate from, so
`api/migrations/001_init.sql` is a minimal placeholder (`patients` table)
built to prove the pipe end-to-end — not the graded app's real schema.
Reconcile it once the actual service exists (Phase 4).

## Right-sizing (Aiven side)

`terraform/modules/data/variables.tf` leaves `aiven_plan` with **no default**
on purpose — plan slugs and pricing change over time. Look yours up before
applying:

```
avn service plan-list --project <aiven_project> mysql
```

## Running Phase 2 locally

```bash
# 1. Terraform (needs AIVEN_TOKEN / TF_VAR_aiven_api_token + LocalStack running)
cd terraform/envs/dev
cp terraform.tfvars.example terraform.tfvars   # fill in project + plan
terraform init && terraform apply

# 2. App
cd ../../api
cp .env.example .env   # fill in DB_SECRET_ARN from the terraform output, or use MYSQL_* fallback
npm install
npm run migrate
npm run seed
npm start
curl localhost:3000/healthz
curl localhost:3000/readyz
curl localhost:3000/debug/secret-source
```

## What's NOT here (group/other-phase work)

`terraform/modules/service` (EC2 + nginx + ALB), the golden CI workflow,
`Makefile`, observability wiring, and k6 incident replay are Phase 1/3/4 —
out of scope for this Phase 2 slice.

## First moves (original starter-pack notes)

1. Read `ASSIGNMENT.md` end to end.
2. Sort your **free Hobby** LocalStack token and a **Linux Codespace** (see
   the Environment section — don't fight a Mac).
