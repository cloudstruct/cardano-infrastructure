terraform {
  required_version = "> 1.1, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}
