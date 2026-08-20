# No endpoint overrides here on purpose. Apply this with `tflocal`
# (https://github.com/localstack/terraform-local) instead of plain `terraform`
# — it wraps every command and injects the LocalStack endpoint/credential
# overrides for whichever AWS services are actually referenced. Same files,
# unmodified, would apply against real AWS with `terraform` directly.

provider "aws" {
  region = var.aws_region
}

# aiven is a real cloud API with no LocalStack emulation — tflocal does not
# and cannot wrap it. modules/data provisions a real Aiven MySQL service
# regardless of which wrapper this root is applied with (see FIDELITY.md).
provider "aiven" {
  api_token = var.aiven_api_token
}
