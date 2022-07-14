# terraform.tf

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-blog"

    workspaces {
      name = "demo-app-on-aws"
    }
  }
}