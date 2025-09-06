variable "region" {
  default = "us-east-1"
}
variable "public_key" {
  
}
variable "private_key" {
  
}
variable "key_name" {
  
}
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
