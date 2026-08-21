# Phase 3 — CI security gates and deployment hardening

This branch is the Phase 3 working branch for the group-owned CI/security work.

## Goal

The platform must enforce guardrails before a change can merge or deploy:

- `gitleaks` for secret scanning
- `trivy` for IaC and image scanning
- `zizmor` for GitHub Actions security review
- Terraform validation before apply

## Current repo state

This repository already contains the Phase 2 app work:

- Secrets Manager integration
- Aiven-backed DB wiring
- health endpoints
- migration and seed steps

The remaining Phase 3 work is the platform and pipeline guardrails.

## Files added in this branch

- `.github/workflows/phase3-security.yml` — starter CI workflow for the gate checks
- `.gitleaks.toml` — beginning secret scan policy
- `.trivy.yaml` — beginning config posture scan defaults

## Next steps to finish the assignment

1. Add the LocalStack runner job and `tflocal` apply flow.
2. Add a Docker build step and Trivy image scan.
3. Pin GitHub Actions to full SHAs for production use.
4. Add a deliberate insecure PR to prove a gate goes red.
5. Save scan artifacts and PR links for the evidence pack.

## Important note

This is a starter scaffold, not the final production-ready pipeline. It gives you the correct gate structure and a clean place to extend the workflow with LocalStack + Terraform + image scanning.
