locals {
  aws_default_region = "us-east-2"

  aws_vpc_default = { for i, vpc in local.network_vars :
    vpc.name => vpc if try(vpc.enabled, true) &&
    try(vpc.cloud_provider, "aws") == "aws" &&
    try(vpc.region, "") == ""
  }

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
}
