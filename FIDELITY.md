# FIDELITY.md — where the emulator lied to you

For each behaviour LocalStack did **not** reproduce faithfully: how you detected
it, and what you'd have to verify in a real AWS account before trusting it. This
is the most transferable thing in the lab — not trusting your test environment is
a senior skill. Fill each with a real detection method, not a guess.

## Group deviation: real Aiven MySQL instead of LocalStack RDS

- **What we did instead:** `terraform/modules/data` provisions a real Aiven
  for MySQL service (`aiven_mysql`) rather than LocalStack's `aws_db_instance`
  RDS emulation. Secrets Manager stays on LocalStack — only the database
  backend moved. This was a deliberate group choice for Phase 2, not a
  LocalStack fidelity gap; it's called out here because it changes what C1/C2
  evidence actually proves.
- **Why:** confirmed by Phase 1's own `terraform/main.tf` comment
  ("module 'data' composes in here once Aiven + Secrets Manager ... is
  ready") — this was the group's plan from the start, not a late change.
  [add the specific reasoning discussed as a group, e.g. wanting real
  InnoDB/lock-wait/connection-limit behaviour for C7's 2202/2203 replay
  without depending on LocalStack's RDS emulation at all.]
- **What this means for evidence:** `evidence/01-iac/apply.log` /
  `plan-after-apply.txt` now include a real cloud API call (Aiven), not a
  LocalStack one — `terraform destroy` has real consequences (a billed
  service, even on the free tier) and isn't idempotent-safe to rerun casually
  the way a LocalStack resource is.
- **What I'd verify on real AWS:** N/A for the DB itself (Aiven MySQL already
  *is* the real managed service) — this caveat is about the assignment's
  target environment, not about trusting an emulator.

## <caveat 1>
- **What LocalStack did:**
- **How I detected it:**
- **What I'd verify on real AWS:**

## <caveat 2>
- **What LocalStack did:**
- **How I detected it:**
- **What I'd verify on real AWS:**

<!-- Starters you'll likely hit (verify each yourself, don't just copy):
  * only the default security group is honoured; custom SGs govern nothing
  * SG ingress rules apply only at instance creation
  * IMDS has no iam/security-credentials/ endpoint
  * storage_encrypted on RDS is returned as configured but not applied
  * the Docker socket is mounted inside the EC2 "instance" (sibling container)
  * ELBv2 health checking is undocumented; the listener port round-trips oddly
-->
