variable "aws_region" {
  description = "Region Terraform targets. LocalStack ignores real regionality, but tflocal still requires one."
  type        = string
  default     = "us-east-1"
}

variable "app_ami_id" {
  description = "Docker-backed EC2 AMI tag CI produces after building + scanning the image, e.g. localstack-ec2/app:ami-<sha12>."
  type        = string
}

variable "aiven_api_token" {
  description = "Aiven personal/application token. Set via TF_VAR_aiven_api_token or AIVEN_TOKEN env var — never commit it."
  type        = string
  sensitive   = true
}

variable "aiven_project" {
  description = "Aiven project name modules/data's MySQL service is created under."
  type        = string
}

variable "aiven_plan" {
  description = "Aiven for MySQL plan slug. Look it up with: avn service plan-list --project <aiven_project> mysql"
  type        = string
}
