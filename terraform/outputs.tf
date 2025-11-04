output "tiffany_server_1_ip" {
  value = aws_instance.tiffany_server_1.public_ip
}
output "tiffany_server_3_ip" {
  value = aws_instance.tiffany_server_3.private_ip
}
output "tiffany_server_4_ip" {
  value = aws_instance.tiffany_server_4.private_ip
}