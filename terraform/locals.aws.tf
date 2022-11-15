locals {
  # IP address
  aws_eip_default = { for i, eip in local.ipaddress_vars :
    eip.name => eip if try(eip.enabled, true) &&
    try(eip.cloud_provider, "aws") == "aws" &&
    try(eip.region, "") == ""
  }

  aws_eip_sa_east1 = { for i, eip in local.ipaddress_vars :
    eip.name => eip if try(eip.enabled, true) &&
    try(eip.cloud_provider, "aws") == "aws" &&
    try(eip.region, "") == "sa-east-1"
  }

  aws_eip_us_east1 = { for i, eip in local.ipaddress_vars :
    eip.name => eip if try(eip.enabled, true) &&
    try(eip.cloud_provider, "aws") == "aws" &&
    try(eip.region, "") == "us-east-1"
  }

  aws_eip_us_east2 = { for i, eip in local.ipaddress_vars :
    eip.name => eip if try(eip.enabled, true) &&
    try(eip.cloud_provider, "aws") == "aws" &&
    try(eip.region, "") == "us-east-2"
  }

  # Network
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

  # Network -> Security Groups
  security_groups = [
    {
      name        = "cardano-node"
      description = "Security group for cardano nodes"
      rules = [
        {
          name        = "ingress-from-anywhere-${var.cardano_port}"
          from_port   = var.cardano_port
          to_port     = var.cardano_port
          protocol    = "tcp"
          description = "Cardano node from anywhere"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          name             = "ingress-from-anywhere-ipv6-${var.cardano_port}"
          from_port        = var.cardano_port
          to_port          = var.cardano_port
          protocol         = "tcp"
          description      = "Cardano node from anywhere"
          ipv6_cidr_blocks = "::/0"
        },
        {
          name        = "egress-to-anywhere-anyport"
          egress      = true
          rule        = ["all-all"]
          description = "all traffic egress to anywhere"
        }
      ]
    }
  ]

  aws_sg_default = flatten([
    for vpcName, vpcConfig in local.aws_vpc_default : [
    for sg in concat(try(vpcConfig.security_groups, []), local.security_groups) : merge({ "vpc" : vpcName }, sg)]
    if try(vpcConfig.enabled, true) &&
    try(vpcConfig.cloud_provider, "aws") == "aws" &&
    try(vpcConfig.region, "") == ""
  ])

  aws_sg_us_east1 = flatten([
    for vpcName, vpcConfig in local.aws_vpc_default : [
    for sg in concat(try(vpcConfig.security_groups, []), local.security_groups) : merge({ "vpc" : vpcName }, sg)]
    if try(vpcConfig.enabled, true) &&
    try(vpcConfig.cloud_provider, "aws") == "aws" &&
    try(vpcConfig.region, "") == "us-east-1"
  ])

  aws_sg_us_east2 = flatten([
    for vpcName, vpcConfig in local.aws_vpc_default : [
    for sg in concat(try(vpcConfig.security_groups, []), local.security_groups) : merge({ "vpc" : vpcName }, sg)]
    if try(vpcConfig.enabled, true) &&
    try(vpcConfig.cloud_provider, "aws") == "aws" &&
    try(vpcConfig.region, "") == "us-east-2"
  ])

  aws_sg_sa_east1 = flatten([
    for vpcName, vpcConfig in local.aws_vpc_default : [
    for sg in concat(try(vpcConfig.security_groups, []), local.security_groups) : merge({ "vpc" : vpcName }, sg)]
    if try(vpcConfig.enabled, true) &&
    try(vpcConfig.cloud_provider, "aws") == "aws" &&
    try(vpcConfig.region, "") == "sa-east-1"
  ])

  # Object Storage
  aws_s3_buckets_default = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "" &&
    try(bucket.terraform_state, false) == false &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_sa_east1 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "sa-east-1" &&
    try(bucket.terraform_state, false) == false &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_us_east1 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "us-east-1" &&
    try(bucket.terraform_state, false) == false &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  aws_s3_buckets_us_east2 = {
    for idx, bucket in local.objectstorage_vars :
    bucket.name => bucket if try(bucket.region, "") == "us-east-2" &&
    try(bucket.terraform_state, false) == false &&
    try(bucket.cloud_provider, "aws") == "aws"
  }

  # Virtual Machines
  aws_vm_default = { for idx, vm in local.vm_vars :
    vm.name => vm if try(vm.enabled, true) &&
    try(vm.cloud_provider, "aws") == "aws" &&
    try(vm.region, "") == ""
  }

  aws_vm_sa_east1 = { for idx, vm in local.vm_vars :
    vm.name => vm if try(vm.enabled, true) &&
    try(vm.cloud_provider, "aws") == "aws" &&
    try(vm.region, "") == "sa-east-1"
  }

  aws_vm_us_east1 = { for idx, vm in local.vm_vars :
    vm.name => vm if try(vm.enabled, true) &&
    try(vm.cloud_provider, "aws") == "aws" &&
    try(vm.region, "") == "us-east-1"
  }

  aws_vm_us_east2 = { for idx, vm in local.vm_vars :
    vm.name => vm if try(vm.enabled, true) &&
    try(vm.cloud_provider, "aws") == "aws" &&
    try(vm.region, "") == "us-east-2"
  }
}
