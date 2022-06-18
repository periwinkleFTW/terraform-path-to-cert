# server/server.tf

variable "subnet_id" {}
variable "size" {
    default = "t2.micro"
}
variable "security_groups" {
  type = list(any)
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

resource "aws_instance" "web_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.size
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = "Web Server from module"
    Terraform = "true"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
output "public_dns" {
  value = aws_instance.web_server.public_dns
}
