resource "aws_eip" "default" {
  provider = aws
  for_each = local.aws_eip_default
  vpc      = true
  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_eip" "sa_east1" {
  provider = aws.sa-east-1
  for_each = local.aws_eip_sa_east1
  vpc      = true
  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_eip" "us_east1" {
  provider = aws.us-east-1
  for_each = local.aws_eip_us_east1
  vpc      = true
  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}

resource "aws_eip" "us_east2" {
  provider = aws.us-east-2
  for_each = local.aws_eip_us_east2
  vpc      = true
  tags = merge(
    local.default_tags,
    {
      Name = "${each.key}"
    },
  )
}
