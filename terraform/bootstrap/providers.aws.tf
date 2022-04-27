# Our default, if no region is provided, is to use us-east-2
provider "aws" {
  region = local.aws_default_region
}
