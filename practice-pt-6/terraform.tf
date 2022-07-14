# terraform.tf

# Local backend
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

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-migration"
#     key            = "dev/aws_infrastructure"
#     region         = "ca-central-1"
#     dynamodb_table = "tf-state-mig"
#     encrypt        = true
#   }
#   # Provider-specific settings
#   required_providers {
#     aws = {
#       version = ">= 2.7.0"
#       source  = "hashicorp/aws"
#     }
#   }
#   # Terraform version
#   required_version = ">= 0.14.9"
# }