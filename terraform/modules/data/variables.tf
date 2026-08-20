# =============================================================================
# modules/data — inputs
#
# DEVIATION FROM ASSIGNMENT.md: this module provisions a real Aiven MySQL
# service instead of LocalStack's RDS emulation (documented in FIDELITY.md /
# README as a deliberate group choice). Secrets Manager stays on LocalStack —
# only the database backend moved off the emulator.
# =============================================================================

variable "aiven_project" {
  description = "Aiven project name the MySQL service is created under."
  type        = string
}

variable "aiven_cloud_name" {
  description = "Aiven cloud/region in <provider>-<region> form, e.g. google-europe-west1. Run `avn cloud list` to see options for your project."
  type        = string
  default     = "google-europe-west1"
}

variable "aiven_plan" {
  description = <<-EOT
    Aiven for MySQL service plan slug (e.g. hobbyist, startup-4). No default on
    purpose — plan availability/pricing varies by project and changes over
    time. Look yours up with:
      avn service plan-list --project <aiven_project> mysql
    or the pricing calculator at https://aiven.io/pricing/calculator, then set
    it in terraform.tfvars.
  EOT
  type        = string
}

variable "service_name" {
  description = "Aiven MySQL service name."
  type        = string
  default     = "regional-health-mysql"
}

variable "mysql_version" {
  description = "MySQL major version passed to mysql_user_config.mysql_version."
  type        = string
  default     = "8"
}

variable "db_name" {
  description = "Application database name. Not created by Terraform (aiven_database was removed in provider v4) — the migration script issues CREATE DATABASE IF NOT EXISTS against this name."
  type        = string
  default     = "capacity_lab"
}

variable "termination_protection" {
  description = "Set true once this is a real, non-throwaway service."
  type        = bool
  default     = false
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret (on LocalStack) holding the DB credential envelope."
  type        = string
  default     = "regional-health/db"
}
