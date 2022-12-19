data "aws_iam_policy_document" "ebs_eip_attach_default" {
  provider = aws
  for_each = local.aws_vm_default

  # Policy allowing attaching the node's EBS volume
  statement {
    actions = [
      "ec2:AttachVolume",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing attaching the node's EIP
  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  # TODO: narrow the scope
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing fetching ansible ZIP from S3
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${try(each.value.s3_bootstrap_bucket, local.bootstrap_bucket.name, each.key)}/*",
    ]
  }
}

data "aws_iam_policy_document" "ebs_eip_attach_sa_east1" {
  provider = aws.sa-east-1
  for_each = local.aws_vm_sa_east1

  # Policy allowing attaching the node's EBS volume
  statement {
    actions = [
      "ec2:AttachVolume",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing attaching the node's EIP
  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  # TODO: narrow the scope
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing fetching ansible ZIP from S3
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${try(each.value.s3_bootstrap_bucket, local.bootstrap_bucket.name, each.key)}/*",
    ]
  }
}

data "aws_iam_policy_document" "ebs_eip_attach_us_east1" {
  provider = aws.us-east-1
  for_each = local.aws_vm_us_east1

  # Policy allowing attaching the node's EBS volume
  statement {
    actions = [
      "ec2:AttachVolume",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing attaching the node's EIP
  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  # TODO: narrow the scope
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing fetching ansible ZIP from S3
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${try(each.value.s3_bootstrap_bucket, local.bootstrap_bucket.name, each.key)}/*",
    ]
  }
}

data "aws_iam_policy_document" "ebs_eip_attach_us_east2" {
  provider = aws.us-east-2
  for_each = local.aws_vm_us_east2

  # Policy allowing attaching the node's EBS volume
  statement {
    actions = [
      "ec2:AttachVolume",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing attaching the node's EIP
  statement {
    actions = [
      "ec2:AssociateAddress",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"

      values = [
        each.value.name,
      ]
    }
  }

  # TODO: narrow the scope
  statement {
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }

  # Policy allowing fetching ansible ZIP from S3
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${try(each.value.s3_bootstrap_bucket, local.bootstrap_bucket.name, each.key)}/*",
    ]
  }
}

resource "aws_iam_policy" "node_default" {
  provider = aws
  for_each = local.aws_vm_default

  name        = each.value.name
  description = "Cardano node policy"
  policy      = data.aws_iam_policy_document.ebs_eip_attach_default[each.key].json
}

resource "aws_iam_policy" "node_sa_east1" {
  provider = aws.sa-east-1
  for_each = local.aws_vm_sa_east1

  name        = each.value.name
  description = "Cardano node policy"
  policy      = data.aws_iam_policy_document.ebs_eip_attach_sa_east1[each.key].json
}

resource "aws_iam_policy" "node_us_east1" {
  provider = aws.us-east-1
  for_each = local.aws_vm_us_east1

  name        = each.value.name
  description = "Cardano node policy"
  policy      = data.aws_iam_policy_document.ebs_eip_attach_us_east1[each.key].json
}

resource "aws_iam_policy" "node_us_east2" {
  provider = aws.us-east-2
  for_each = local.aws_vm_us_east2

  name        = each.value.name
  description = "Cardano node policy"
  policy      = data.aws_iam_policy_document.ebs_eip_attach_us_east2[each.key].json
}
