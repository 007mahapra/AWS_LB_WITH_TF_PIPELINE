terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.39.0"
    }
  }
}

# Provider block for AWS
provider "aws" {
  region = "ap-southeast-1"
}
