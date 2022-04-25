module "aws_vpc_default" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  providers = {
    aws = aws
  }

  for_each = local.aws_vpc_default

  name = each.value.name

  cidr            = try(each.value.cidr, "10.0.0.0/16")
  azs             = try(each.value.azs, ["us-east-2c"])
  private_subnets = try(each.value.private_subnets, ["10.0.1.0/24"])
  public_subnets  = try(each.value.public_subnets, ["10.0.101.0/24"])

  enable_dns_hostnames = true
  enable_nat_gateway   = false
}

module "aws_vpc_sa_east1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  providers = {
    aws = aws.sa-east-1
  }

  for_each = local.aws_vpc_sa_east1

  name = each.value.name

  cidr            = try(each.value.cidr, "10.0.0.0/16")
  azs             = try(each.value.azs, ["us-east-1c"])
  private_subnets = try(each.value.private_subnets, ["10.0.1.0/24"])
  public_subnets  = try(each.value.public_subnets, ["10.0.101.0/24"])

  enable_dns_hostnames = true
  enable_nat_gateway   = false
}

module "aws_vpc_us_east1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  providers = {
    aws = aws.us-east-1
  }

  for_each = local.aws_vpc_us_east1

  name = each.value.name

  cidr            = try(each.value.cidr, "10.0.0.0/16")
  azs             = try(each.value.azs, ["us-east-1c"])
  private_subnets = try(each.value.private_subnets, ["10.0.1.0/24"])
  public_subnets  = try(each.value.public_subnets, ["10.0.101.0/24"])

  enable_dns_hostnames = true
  enable_nat_gateway   = false
}

module "aws_vpc_us_east2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  providers = {
    aws = aws.us-east-2
  }

  for_each = local.aws_vpc_us_east2

  name = each.value.name

  cidr            = try(each.value.cidr, "10.0.0.0/16")
  azs             = try(each.value.azs, ["us-east-2c"])
  private_subnets = try(each.value.private_subnets, ["10.0.1.0/24"])
  public_subnets  = try(each.value.public_subnets, ["10.0.101.0/24"])

  enable_dns_hostnames = true
  enable_nat_gateway   = false
}
