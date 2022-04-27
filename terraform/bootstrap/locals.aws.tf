locals {
  # This must be specified manually in terraform/cardano-infrastructure/versions.tf backend block
  aws_default_region = "us-east-2"

  # Object Storage
  aws_s3_buckets_default = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "" &&
    try(bucket.cloud_provider, "aws") == "aws" &&
    try(bucket.bootstrap, false)
  }

  # NoSQL
  aws_nosql_default = {
    for idx, nosql in local.nosql_vars :
    nosql.name => nosql if try(nosql.region, "") == "" &&
    try(nosql.cloud_provider, "aws") == "aws" &&
    try(nosql.bootstrap, false)
  }

}
