# Since terraform does not allow dynamic providers, we need one for each region

# Our default, if no region is provided, is to use us-east-1
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}
