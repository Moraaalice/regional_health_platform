variable "aiven_api_token" {
  description = "Aiven personal/application token. Set via TF_VAR_aiven_api_token or AIVEN_TOKEN env var — never commit it."
  type        = string
  sensitive   = true
}

variable "aiven_project" {
  description = "Aiven project name."
  type        = string
}

variable "aiven_plan" {
  description = "Aiven for MySQL plan slug. Look it up with: avn service plan-list --project <aiven_project> mysql"
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret name."
  type        = string
  default     = "regional-health/db"
}

variable "db_name" {
  description = "Application database name."
  type        = string
  default     = "capacity_lab"
}
