variable "aws_region" {
  description = "Region Terraform targets. LocalStack ignores real regionality, but tflocal still requires one."
  type        = string
  default     = "us-east-1"
}

variable "app_ami_id" {
  description = "Docker-backed EC2 AMI tag CI produces after building + scanning the image, e.g. localstack-ec2/app:ami-<sha12>."
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding the Aiven MySQL credentials envelope. Plain variable for now so this root can plan on its own; once modules/data (Aiven + Secrets Manager) lands, wire this from its output instead."
  type        = string
}

variable "db_endpoint" {
  description = "Aiven MySQL host. Same story as db_secret_arn — comes from modules/data once it exists."
  type        = string
}

variable "db_port" {
  description = "Aiven MySQL port."
  type        = number
  default     = 3306
}
