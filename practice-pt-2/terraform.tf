# terraform.tf

terraform {
  # Provider-specific settings
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
  # Terraform version
  required_version = ">= 0.14.9"
}