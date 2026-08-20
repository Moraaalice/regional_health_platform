# Partial backend config on purpose — bucket/table names come from the
# group's bootstrap script (S3 state bucket + DynamoDB lock table), not from
# this file. Initialize with:
#
#   tflocal init -backend-config=backend.hcl
#
# where backend.hcl (gitignored, one per person) supplies:
#   bucket, key, region, dynamodb_table

terraform {
  backend "s3" {}
}
