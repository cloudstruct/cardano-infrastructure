module "s3_logging_bucket_tfstate" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if try(bucketConfig.logging, false)
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower("${each.key}-logging")

  acl = "private"

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

}

module "s3_tfstate_bucket_with_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if try(bucketConfig.logging, false)
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  logging = {
    target_bucket = module.s3_logging_bucket_tfstate[each.key].s3_bucket_id
    target_prefix = "log/"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "s3_tfstate_bucket_without_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if !try(bucketConfig.logging, false)
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
