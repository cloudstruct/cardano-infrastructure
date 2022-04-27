terraform {
  required_version = "> 1.1"

  #  backend "s3" {
  #    region         = "us-east-2"
  #    bucket         = "cardano-infrastructure-tfstate"
  #    key            = "cardanoinfra.tfstate"
  #    dynamodb_table = "terraform-state-lock"
  #    encrypt        = true
  #  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.11.0"
    }
  }
}
