# modules/server/outputs.tf

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
output "public_dns" {
  value = aws_instance.web_server.public_dns
}