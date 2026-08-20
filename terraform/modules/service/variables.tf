variable "app_ami_id" {
  description = "Docker-backed EC2 AMI tag CI produces after building + scanning the image (localstack-ec2/app:ami-<sha12>)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "secret_arn" {
  description = "Secrets Manager ARN for the DB credentials envelope. Passed into user-data; the app resolves the value itself at boot via GetSecretValue — Terraform never sees or logs it."
  type        = string
}

variable "db_endpoint" {
  description = "DB host, passed into user-data alongside the secret ARN."
  type        = string
}

variable "db_port" {
  description = "DB port."
  type        = number
  default     = 3306
}

variable "app_port" {
  description = "Port the app listens on inside the instance."
  type        = number
  default     = 3000
}
