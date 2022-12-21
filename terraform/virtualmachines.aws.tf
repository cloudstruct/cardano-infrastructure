locals {
  # Get security group created within VPCs as specified by precedence of
  # (virtual_machines.instances[x].vpc, virtual_machines.instances[x].name)
  # With security group name precedence of
  # (virtual_machines.instances[x].security_group_name, (virtual_machines.instances[x].name)
  default_aws_vms_sgs = flatten([
    for vm in local.aws_vm_default : [
      for sg in local.aws_sg_default : try(
        module.aws_sg_default["${vm.vpc}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_default["${vm.vpc}#${vm.name}"].security_group_id,
        module.aws_sg_default["${vm.name}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_default["${vm.name}#${vm.name}"].security_group_id,
        []
      ) if sg.vpc == try(vm.vpc, vm.name)
    ]
  ])
  default_vpc_az = try([for az in module.aws_vpc_default["cardano-node"].azs : az if length(module.aws_vpc_default["cardano-node"].azs) == 1][0], false)

  sa_east1_aws_vms_sgs = flatten([
    for vm in local.aws_vm_sa_east1 : [
      for sg in local.aws_sg_sa_east1 : try(
        module.aws_sg_sa_east1["${vm.vpc}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_sa_east1["${vm.vpc}#${vm.name}"].security_group_id,
        module.aws_sg_sa_east1["${vm.name}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_sa_east1["${vm.name}#${vm.name}"].security_group_id,
        []
      ) if sg.vpc == try(vm.vpc, vm.name)
    ]
  ])

  us_east1_aws_vms_sgs = flatten([
    for vm in local.aws_vm_us_east1 : [
      for sg in local.aws_sg_us_east1 : try(
        module.aws_sg_us_east1["${vm.vpc}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_us_east1["${vm.vpc}#${vm.name}"].security_group_id,
        module.aws_sg_us_east1["${vm.name}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_us_east1["${vm.name}#${vm.name}"].security_group_id,
        []
      ) if sg.vpc == try(vm.vpc, vm.name)
    ]
  ])

  us_east2_aws_vms_sgs = flatten([
    for vm in local.aws_vm_us_east2 : [
      for sg in local.aws_sg_us_east2 : try(
        module.aws_sg_us_east2["${vm.vpc}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_us_east2["${vm.vpc}#${vm.name}"].security_group_id,
        module.aws_sg_us_east2["${vm.name}#${vm.security_group_name}"].security_group_id,
        module.aws_sg_us_east2["${vm.name}#${vm.name}"].security_group_id,
        []
      ) if sg.vpc == try(vm.vpc, vm.name)
    ]
  ])

  all_relays         = [for vm in local.machine_vars : vm.name if try(vm.block_producer, false) == false]
  vm_instance_relays = { for vm in local.machine_vars : vm.name => try(vm.relays, local.all_relays) }

}

resource "aws_ebs_volume" "node_data_default" {
  provider = aws
  for_each = local.aws_vm_default

  availability_zone = local.default_vpc_az != false ? local.default_vpc_az : try(each.value.az, local.machine_vars.default_availability_zone, "us-east-1c")

  size = try(each.value.data_volume_size, local.machine_vars.default_data_volume_size, 120)
  type = "gp3"

  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_ebs_volume" "node_data_sa_east1" {
  provider = aws.sa-east-1
  for_each = local.aws_vm_sa_east1

  availability_zone = local.default_vpc_az != false ? local.default_vpc_az : try(each.value.az, local.machine_vars.default_availability_zone, "sa-east-1c")

  size = try(each.value.data_volume_size, local.machine_vars.default_data_volume_size, 120)
  type = "gp3"

  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_ebs_volume" "node_data_us_east1" {
  provider = aws.us-east-1
  for_each = local.aws_vm_us_east1

  availability_zone = local.default_vpc_az != false ? local.default_vpc_az : try(each.value.az, local.machine_vars.default_availability_zone, "us-east-1c")

  size = try(each.value.data_volume_size, local.machine_vars.default_data_volume_size, 120)
  type = "gp3"

  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_ebs_volume" "node_data_us_east2" {
  provider = aws.us-east-2
  for_each = local.aws_vm_us_east2

  availability_zone = local.default_vpc_az != false ? local.default_vpc_az : try(each.value.az, local.machine_vars.default_availability_zone, "us-east-2c")

  size = try(each.value.data_volume_size, local.machine_vars.default_data_volume_size, 120)
  type = "gp3"

  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

data "aws_ami" "ubuntu_default" {
  provider = aws
  for_each = local.aws_vm_default

  most_recent = try(each.value.ami.most_recent, true)

  filter {
    name   = "name"
    values = try(each.value.ami.name, ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"])
  }

  filter {
    name   = "virtualization-type"
    values = try(each.value.ami.virtualization_type, ["hvm"])
  }

  # Canonical
  owners = try(each.value.ami.owners, ["099720109477"])
}

data "aws_ami" "ubuntu_sa_east1" {
  provider = aws.sa-east-1
  for_each = local.aws_vm_sa_east1

  most_recent = try(each.value.ami.most_recent, true)

  filter {
    name   = "name"
    values = try(each.value.ami.name, ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"])
  }

  filter {
    name   = "virtualization-type"
    values = try(each.value.ami.virtualization_type, ["hvm"])
  }

  # Canonical
  owners = try(each.value.ami.owners, ["099720109477"])
}

data "aws_ami" "ubuntu_us_east1" {
  provider = aws.us-east-1
  for_each = local.aws_vm_us_east1

  most_recent = try(each.value.ami.most_recent, true)

  filter {
    name   = "name"
    values = try(each.value.ami.name, ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"])
  }

  filter {
    name   = "virtualization-type"
    values = try(each.value.ami.virtualization_type, ["hvm"])
  }

  # Canonical
  owners = try(each.value.ami.owners, ["099720109477"])
}

data "aws_ami" "ubuntu_us_east2" {
  provider = aws.us-east-2
  for_each = local.aws_vm_us_east2

  most_recent = try(each.value.ami.most_recent, true)

  filter {
    name   = "name"
    values = try(each.value.ami.name, ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"])
  }

  filter {
    name   = "virtualization-type"
    values = try(each.value.ami.virtualization_type, ["hvm"])
  }

  # Canonical
  owners = try(each.value.ami.owners, ["099720109477"])
}

module "virtual_machines_default" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  providers = { aws = aws }

  for_each = local.aws_vm_default

  name          = each.value.name
  image_id      = data.aws_ami.ubuntu_default[each.key].image_id
  instance_type = try(each.value.instance_type, local.machine_vars.default_instance_type, "m6g.large")
  key_name      = try(each.value.key_name, null)

  user_data = try(
    base64encode(
      templatefile(
        "${path.root}/../templates/cloudinit/${try(each.value.cloudinit_template, "cardano-node.aws.tftpl")}",
        {
          EBS_VOLUME_ID                   = aws_ebs_volume.node_data_default[each.key].id
          OBJECT_STORAGE_BOOTSTRAP_BUCKET = local.bootstrap_bucket
          CARDANO_RELAY_LIST              = local.vm_instance_relays[each.key]
        }
      ),
    ),
    null
  )

  min_size         = try(each.value.min_size, 1)
  max_size         = try(each.value.max_size, 1)
  desired_capacity = try(each.value.desired_capacity, 1)

  health_check_type      = "EC2"
  update_default_version = true
  enable_monitoring      = true
  vpc_zone_identifier    = try(module.aws_vpc_default[each.key].private_subnets, module.aws_vpc_default[each.key].private_subnets)

  create_iam_instance_profile = true
  iam_role_name               = each.value.name
  iam_role_description        = "IAM role for instance ${each.value.name}"
  iam_role_tags               = merge(local.default_tags, try(each.value.tags, {}))
  iam_role_policies           = { (each.key) = aws_iam_policy.node_default[each.key].arn }

  security_groups = try(each.value.sg_ids, local.default_aws_vms_sgs, null)

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

  metadata_options = {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  tags = merge(local.default_tags, try(each.value.tags, {}))
}

module "virtual_machines_sa_east1" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  providers = { aws = aws.sa-east-1 }

  for_each = local.aws_vm_sa_east1

  name          = each.value.name
  image_id      = data.aws_ami.ubuntu_sa_east1[each.key].image_id
  instance_type = try(each.value.instance_type, local.machine_vars.default_instance_type, "m6g.large")
  key_name      = try(each.value.key_name, null)

  user_data = try(
    base64encode(
      templatefile(
        "${path.root}/../templates/cloudinit/${try(each.value.cloudinit_template, "cardano-node.aws.tftpl")}",
        {
          EBS_VOLUME_ID                   = aws_ebs_volume.node_data_sa_east1[each.key].id
          OBJECT_STORAGE_BOOTSTRAP_BUCKET = local.bootstrap_bucket
          CARDANO_RELAY_LIST              = local.vm_instance_relays[each.key]
        }
      ),
    ),
    null
  )

  min_size         = try(each.value.min_size, 1)
  max_size         = try(each.value.max_size, 1)
  desired_capacity = try(each.value.desired_capacity, 1)

  health_check_type      = "EC2"
  update_default_version = true
  enable_monitoring      = true
  vpc_zone_identifier    = try(module.aws_vpc_sa_east1[each.key].private_subnets, module.aws_vpc_sa_east1[each.key].private_subnets)

  create_iam_instance_profile = true
  iam_role_name               = each.value.name
  iam_role_description        = "IAM role for instance ${each.value.name}"
  iam_role_tags               = merge(local.default_tags, try(each.value.tags, {}))
  iam_role_policies           = { (each.key) = aws_iam_policy.node_sa_east1[each.key].arn }

  security_groups = try(each.value.sg_ids, local.sa_east1_aws_vms_sgs, null)

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

  metadata_options = {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  tags = merge(local.default_tags, try(each.value.tags, {}))
}

module "virtual_machines_us_east1" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  providers = { aws = aws.us-east-1 }

  for_each = local.aws_vm_us_east1

  name          = each.value.name
  image_id      = data.aws_ami.ubuntu_us_east1[each.key].image_id
  instance_type = try(each.value.instance_type, local.machine_vars.default_instance_type, "m6g.large")
  key_name      = try(each.value.key_name, null)

  user_data = try(
    base64encode(
      templatefile(
        "${path.root}/../templates/cloudinit/${try(each.value.cloudinit_template, "cardano-node.aws.tftpl")}",
        {
          EBS_VOLUME_ID                   = aws_ebs_volume.node_data_us_east1[each.key].id
          OBJECT_STORAGE_BOOTSTRAP_BUCKET = local.bootstrap_bucket
          CARDANO_RELAY_LIST              = local.vm_instance_relays[each.key]
        }
      ),
    ),
    null
  )

  min_size         = try(each.value.min_size, 1)
  max_size         = try(each.value.max_size, 1)
  desired_capacity = try(each.value.desired_capacity, 1)

  health_check_type      = "EC2"
  update_default_version = true
  enable_monitoring      = true
  vpc_zone_identifier    = try(module.aws_vpc_us_east1[each.key].private_subnets, module.aws_vpc_us_east1[each.key].private_subnets)

  create_iam_instance_profile = true
  iam_role_name               = each.value.name
  iam_role_description        = "IAM role for instance ${each.value.name}"
  iam_role_tags               = merge(local.default_tags, try(each.value.tags, {}))
  iam_role_policies           = { (each.key) = aws_iam_policy.node_us_east1[each.key].arn }

  security_groups = try(each.value.sg_ids, local.us_east1_aws_vms_sgs, null)

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

  metadata_options = {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  tags = merge(local.default_tags, try(each.value.tags, {}))
}

module "virtual_machines_us_east2" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  providers = { aws = aws.us-east-2 }

  for_each = local.aws_vm_us_east2

  name          = each.value.name
  image_id      = data.aws_ami.ubuntu_us_east2[each.key].image_id
  instance_type = try(each.value.instance_type, local.machine_vars.default_instance_type, "m6g.large")
  key_name      = try(each.value.key_name, null)

  user_data = try(
    base64encode(
      templatefile(
        "${path.root}/../templates/cloudinit/${try(each.value.cloudinit_template, "cardano-node.aws.tftpl")}",
        {
          EBS_VOLUME_ID                   = aws_ebs_volume.node_data_us_east2[each.key].id
          OBJECT_STORAGE_BOOTSTRAP_BUCKET = local.bootstrap_bucket
          CARDANO_RELAY_LIST              = local.vm_instance_relays[each.key]
        }
      ),
    ),
    null
  )

  min_size         = try(each.value.min_size, 1)
  max_size         = try(each.value.max_size, 1)
  desired_capacity = try(each.value.desired_capacity, 1)

  health_check_type      = "EC2"
  update_default_version = true
  enable_monitoring      = true
  vpc_zone_identifier    = try(module.aws_vpc_us_east2[each.key].private_subnets, module.aws_vpc_us_east2[each.key].private_subnets)

  create_iam_instance_profile = true
  iam_role_name               = each.value.name
  iam_role_description        = "IAM role for instance ${each.value.name}"
  iam_role_tags               = merge(local.default_tags, try(each.value.tags, {}))
  iam_role_policies           = { (each.key) = aws_iam_policy.node_us_east2[each.key].arn }

  security_groups = try(each.value.sg_ids, local.us_east2_aws_vms_sgs, null)

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

  metadata_options = {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 32
    instance_metadata_tags      = "enabled"
  }

  tags = merge(local.default_tags, try(each.value.tags, {}))
}
