# =============================================================================
# envs/dev — standalone test harness for modules/data (Phase 2 evidence only)
#
# Composes ONLY the data module so it can be applied/destroyed in isolation
# for C2/C3 evidence (evidence/02-data, evidence/03-secrets) before
# modules/service exists. The real root that composes data + service is group
# work, not part of this.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = ">= 4.0.0, < 5.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  backend "local" {}
}

provider "aiven" {
  api_token = var.aiven_api_token
}

# Only Secrets Manager needs to exist on LocalStack for this harness.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    secretsmanager = "http://localhost:4566"
  }
}

module "data" {
  source = "../../modules/data"

  aiven_project = var.aiven_project
  aiven_plan    = var.aiven_plan
  secret_name   = var.secret_name
  db_name       = var.db_name
}
