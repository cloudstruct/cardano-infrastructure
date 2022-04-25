<<<<<<< HEAD
module "s3_logging_bucket_default" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  providers = {
    aws = aws
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower("${each.key}-logging")

  acl = try(each.value.acl, "private")

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

module "s3_logging_bucket_sa_east1" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_sa_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  providers = {
    aws = aws.sa-east-1
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower("${each.key}-logging")

  acl = try(each.value.acl, "private")

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

module "s3_logging_bucket_us_east1" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  providers = {
    aws = aws.us-east-1
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower("${each.key}-logging")

  acl = try(each.value.acl, "private")

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

module "s3_logging_bucket_us_east2" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east2 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  providers = {
    aws = aws.us-east-1
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = lower("${each.key}-logging")

  acl = try(each.value.acl, "private")

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

module "s3_buckets_default_with_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws
  }

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  logging = {
    target_bucket = module.s3_logging_bucket_default[each.key].s3_bucket_id
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

module "s3_buckets_default_without_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_default :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == false
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws
  }

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

module "s3_buckets_sa_east1_with_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_sa_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.sa-east-1
  }

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  logging = {
    target_bucket = module.s3_logging_bucket_sa_east1[each.key].s3_bucket_id
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

module "s3_buckets_sa_east1_without_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_sa_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == false
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.sa-east-1
  }

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

module "s3_buckets_us_east1_with_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.us-east-1
  }

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  logging = {
    target_bucket = module.s3_logging_bucket_us_east1[each.key].s3_bucket_id
    target_prefix = "log/"
=======
module "s3_logging_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket = local.config.aws["infrastructure"].s3.buckets.logging.name

  acl = local.config.aws["infrastructure"].s3.buckets.logging.acl

  versioning = {
    enabled = local.config.aws["infrastructure"].s3.buckets.logging.versioning
>>>>>>> Implement s3 bucket handling and modules
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
<<<<<<< HEAD
        sse_algorithm = "AES256"
=======
        sse_algorithm     = "AES256"
>>>>>>> Implement s3 bucket handling and modules
      }
    }
  }

}

<<<<<<< HEAD
module "s3_buckets_us_east1_without_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east1 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == false
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.us-east-1
  }

  bucket = lower(each.key)
=======
module "s3_buckets" {
  for_each = local.aws_s3_bucket_map
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  bucket   = lower("${each.key}")
>>>>>>> Implement s3 bucket handling and modules

  acl = try(each.value.acl, "private")

  versioning = {
<<<<<<< HEAD
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

module "s3_buckets_us_east2_with_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east2 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == true
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.us-east-1
  }

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
  }

  logging = {
    target_bucket = module.s3_logging_bucket_us_east2[each.key].s3_bucket_id
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

module "s3_buckets_us_east2_without_logging" {
  for_each = {
    for bucketName, bucketConfig in local.aws_s3_buckets_us_east2 :
    bucketName => bucketConfig if try(bucketConfig.logging, false) == false
  }

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.1.0"

  providers = {
    aws = aws.us-east-1
  }

  bucket = lower(each.key)

  acl = try(each.value.acl, "private")

  versioning = {
    enabled = try(each.value.versioning, false)
=======
    enabled = try(each.value.versioning, true)
  }

  logging = {
     target_bucket = module.s3_logging_bucket.s3_bucket_id
     target_prefix = "log/"
>>>>>>> Implement s3 bucket handling and modules
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
<<<<<<< HEAD
        sse_algorithm = "AES256"
=======
        sse_algorithm     = "AES256"
>>>>>>> Implement s3 bucket handling and modules
      }
    }
  }

}
