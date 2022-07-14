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

resource "aws_subnet" "private_subnet" {
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

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "demo_igw"
    Terraform = "true"
  }
}

# NAT gateway EIP
resource "aws_eip" "nat_gateway_eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.internet_gateway
  ]

  tags = {
    Name      = "demo_nat_gateway"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnet]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name      = "demo_nat_gateway"
    Terraform = "true"
  }
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnet]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

# Private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }

}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnet]
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

module "my_server_module" {
  # location of module directory
  source          = "./modules/server"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public_sg.id]
}

module "another_server_from_a_module" {
  # location of module directory
  source          = "./modules/server"
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]
}

module "_server_from_local_module" {
  # local module
  source          = "./modules/server"
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "autoscaling_from_registry" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.0"

  name = "demo_module_asg"

  vpc_zone_identifier = [aws_subnet.private_subnet.id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name      = "Web servers from asg module"
    Terraform = "true"
  }
}

module "autoscaling_from_github" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling"

  name = "demo_module_asg"

  vpc_zone_identifier = [aws_subnet.private_subnet.id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name      = "Web servers from asg module"
    Terraform = "true"
  }
}

output "public_ip" {
  value = module.my_server_module.public_ip
}