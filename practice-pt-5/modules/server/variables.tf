# modules/server/variables.tf

variable "subnet_id" {}
variable "size" {
    default = "t2.micro"
}
variable "security_groups" {
  type = list(any)
}