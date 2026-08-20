# No endpoint overrides here on purpose. Apply this with `tflocal`
# (https://github.com/localstack/terraform-local) instead of plain `terraform`
# — it wraps every command and injects the LocalStack endpoint/credential
# overrides for whichever AWS services are actually referenced. Same files,
# unmodified, would apply against real AWS with `terraform` directly.

provider "aws" {
  region = var.aws_region
}
