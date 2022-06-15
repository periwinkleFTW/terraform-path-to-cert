# main.tf

provider "aws" {
  # This is how we access variables
  region = var.aws_region
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

# Subnets 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name      = "My Public Subnet"
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name      = "My Private Subnet"
    Terraform = "true"
  }
}

# Public Security Group
resource "aws_security_group" "public_sg" {
  name        = "Public Security Group"
  description = "Public internet access"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name     = "Security Group for Public Subnet"
    Teraform = "true"
  }
}

# rule for allowing all outgoing traffic
resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public_sg.id

}

# rule for allowing ssh traffic for public sg
resource "aws_security_group_rule" "public_ssh_in" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public_sg.id
}

# rule for allowing http traffic for public sg
resource "aws_security_group_rule" "public_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public_sg.id
}

# rule for allowing https traffic for public sg
resource "aws_security_group_rule" "public_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public_sg.id
}

# Private Security Group
resource "aws_security_group" "private_sg" {
  name        = "Private Security Group"
  description = "Private internet access"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name     = "Security Group for Private Subnet"
    Teraform = "true"
  }
}

resource "aws_security_group_rule" "private_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.private_sg.id
}

resource "aws_security_group_rule" "private_in" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = [var.vpc_cidr]

  security_group_id = aws_security_group.private_sg.id
}