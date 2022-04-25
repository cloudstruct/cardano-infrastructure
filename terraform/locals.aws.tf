locals {
  # Network
  aws_vpc_default = { for i, vpc in local.network_vars :
    vpc.name => vpc if try(vpc.enabled, true) &&
    try(vpc.cloud_provider, "aws") == "aws" &&
    try(vpc.region, "") == ""
  }

  aws_s3_bucket_list = flatten([
    for network, networkConfig in local.aws_vpc_default :
    flatten([
      for bucketName, bucketConfig in try(local.config.aws[network].s3.buckets, {}) :
      {
        "name"       = bucketName,
        "acl"        = bucketConfig.acl,
        "versioning" = bucketConfig.versioning
        "network"    = network
      }
    ])
  ])

  aws_s3_bucket_map = { for idx, bucket in local.aws_s3_bucket_list : "${bucket.network}-${bucket.name}" => bucket }

  aws_vpc_sa_east1 = { for i, vpc in local.network_vars :
    vpc.name => vpc if try(vpc.enabled, true) &&
    try(vpc.cloud_provider, "aws") == "aws" &&
    try(vpc.region, "") == "sa-east-1"
  }

  aws_vpc_us_east1 = { for i, vpc in local.network_vars :
    vpc.name => vpc if try(vpc.enabled, true) &&
    try(vpc.cloud_provider, "aws") == "aws" &&
    try(vpc.region, "") == "us-east-1"
  }

  aws_vpc_us_east2 = { for i, vpc in local.network_vars :
    vpc.name => vpc if try(vpc.enabled, true) &&
    try(vpc.cloud_provider, "aws") == "aws" &&
    try(vpc.region, "") == "us-east-2"
  }

  # Object Storage
  aws_s3_buckets_default = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "" &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_sa_east1 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "sa-east-1" &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_us_east1 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "us-east-1" &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_us_east2 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "us-east-2" &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

}
