# =============================================================================
# modules/data — Aiven MySQL + Secrets Manager (LocalStack)   (Phase 2 / Member 2)
#
# Provisions a real Aiven for MySQL service and publishes its connection
# details to a LocalStack-emulated Secrets Manager secret using the envelope
# the rest of the stack expects: { engine, username, password, host, port,
# dbname }. No plaintext secret in git, state is the only place it lands
# (see ASSIGNMENT.md C3 — treat the state file as a credential store).
#
# DEVIATION: ASSIGNMENT.md specifies RDS MySQL emulated by LocalStack for C2.
# This module uses a real Aiven MySQL service instead; only Secrets Manager
# stays on LocalStack. See FIDELITY.md for the documented trade-off.
#
# aiven_database / aiven_service_user were removed in provider v4 — there is
# no Terraform-managed "app" database or non-admin user. The migration script
# (api/migrations) issues `CREATE DATABASE IF NOT EXISTS <db_name>` and runs
# as the service's default admin user.
# =============================================================================

resource "aiven_mysql" "db" {
  project                = var.aiven_project
  cloud_name             = var.aiven_cloud_name
  plan                   = var.aiven_plan
  service_name           = var.service_name
  termination_protection = var.termination_protection

  mysql_user_config {
    mysql_version = var.mysql_version
  }
}

resource "aws_secretsmanager_secret" "db" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    engine   = "mysql"
    username = aiven_mysql.db.service_username
    password = aiven_mysql.db.service_password
    host     = aiven_mysql.db.service_host
    port     = aiven_mysql.db.service_port
    dbname   = var.db_name
  })
}
