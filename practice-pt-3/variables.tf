# variables.tf

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "vpc_name" {
  type    = string
  default = "TerraformCertPrep_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  default = {
    "public_subnet_1" = 1
  }
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet" {
  default = {
    "private_subnet_1" = 1
  }
}