# Terraform Providers to Use
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "eu-west-2"
}