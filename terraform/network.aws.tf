module "aws_vpc_default" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.15.0"

  providers = { aws = aws }

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
  version = "3.15.0"

  providers = { aws = aws.sa-east-1 }

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
  version = "3.15.0"

  providers = { aws = aws.us-east-1 }

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
  version = "3.15.0"

  providers = { aws = aws.us-east-2 }

  for_each = local.aws_vpc_us_east2

  name = each.value.name

  cidr            = try(each.value.cidr, "10.0.0.0/16")
  azs             = try(each.value.azs, ["us-east-2c"])
  private_subnets = try(each.value.private_subnets, ["10.0.1.0/24"])
  public_subnets  = try(each.value.public_subnets, ["10.0.101.0/24"])

  enable_dns_hostnames = true
  enable_nat_gateway   = false
}

module "aws_sg_default" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  for_each = { for sg in local.aws_sg_default : sg.name => sg }

  providers = { aws = aws }

  name            = each.key
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])
  computed_ingress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)])

  computed_egress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)])
  computed_egress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)])

}

# Security groups using other security group IDs as ingress/egress ranges
module "aws_source_sgs_default" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  providers = { aws = aws }

  for_each = { for sg in local.aws_sg_default : sg.name => sg }

  name            = "${each.key}-source-sgs"
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_default[sg.ingress_sg_name].security_group_id }) if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])

  computed_egress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_default[sg.egress_sg_name].security_group_id }) if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)]
  number_of_computed_egress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)])

}

module "aws_sg_us_east1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  for_each = { for sg in local.aws_sg_us_east1 : sg.name => sg }

  providers = { aws = aws.us-east-1 }

  name            = each.key
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])
  computed_ingress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)])

  computed_egress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)])
  computed_egress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)])

}

# Security groups using other security group IDs as ingress/egress ranges
module "aws_source_sgs_us_east1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  providers = { aws = aws.us-east-1 }

  for_each = { for sg in local.aws_sg_us_east1 : sg.name => sg }

  name            = "${each.key}-source-sgs"
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_us_east1[sg.ingress_sg_name].security_group_id }) if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])

  computed_egress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_us_east1[sg.egress_sg_name].security_group_id }) if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)]
  number_of_computed_egress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)])

}

module "aws_sg_us_east2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  for_each = { for sg in local.aws_sg_us_east2 : sg.name => sg }

  providers = { aws = aws.us-east-2 }

  name            = each.key
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])
  computed_ingress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)])

  computed_egress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)])
  computed_egress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)])

}

# Security groups using other security group IDs as ingress/egress ranges
module "aws_source_sgs_us_east2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  providers = { aws = aws.us-east-2 }

  for_each = { for sg in local.aws_sg_us_east2 : sg.name => sg }

  name            = "${each.key}-source-sgs"
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_us_east2[sg.ingress_sg_name].security_group_id }) if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])

  computed_egress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_us_east2[sg.egress_sg_name].security_group_id }) if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)]
  number_of_computed_egress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)])

}

module "aws_sg_sa_east1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  for_each = { for sg in local.aws_sg_sa_east1 : sg.name => sg }

  providers = { aws = aws.sa-east-1 }

  name            = each.key
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])
  computed_ingress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && !can(sg.egress)])

  computed_egress_with_cidr_blocks                = [for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_cidr_blocks      = length([for sg in each.value.rules : sg if can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && can(sg.egress)])
  computed_egress_with_ipv6_cidr_blocks           = [for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)]
  number_of_computed_egress_with_ipv6_cidr_blocks = length([for sg in each.value.rules : sg if can(sg.ipv6_cidr_blocks) && !can(sg.cidr_blocks) && can(sg.egress)])

}

# Security groups using other security group IDs as ingress/egress ranges
module "aws_source_sgs_sa_east1" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  providers = { aws = aws.sa-east-1 }

  for_each = { for sg in local.aws_sg_sa_east1 : sg.name => sg }

  name            = "${each.key}-source-sgs"
  use_name_prefix = false

  description = each.value.description
  vpc_id      = module.aws_vpc_default[each.value.vpc].vpc_id

  computed_ingress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_sa_east1[sg.ingress_sg_name].security_group_id }) if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)]
  number_of_computed_ingress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.ingress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks) && !can(sg.egress)])

  computed_egress_with_source_security_group_id           = [for sg in each.value.rules : merge(sg, { "source_security_group_id" : module.aws_sg_sa_east1[sg.egress_sg_name].security_group_id }) if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)]
  number_of_computed_egress_with_source_security_group_id = length([for sg in each.value.rules : sg if can(sg.egress) && can(sg.egress_sg_name) && !can(sg.cidr_blocks) && !can(sg.ipv6_cidr_blocks)])

}
