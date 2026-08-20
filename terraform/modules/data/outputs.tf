output "db_endpoint" {
  description = "Aiven MySQL service hostname."
  value       = aiven_mysql.db.service_host
}

output "db_port" {
  description = "Aiven MySQL service port."
  value       = aiven_mysql.db.service_port
}

output "db_name" {
  description = "Application database name (created by the migration script, not Terraform)."
  value       = var.db_name
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB credential envelope. Pass this into modules/service user-data — never the secret value."
  value       = aws_secretsmanager_secret.db.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret holding the DB credential envelope."
  value       = aws_secretsmanager_secret.db.name
}
