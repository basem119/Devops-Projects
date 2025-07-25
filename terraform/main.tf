terraform{
    required_providers{
        aws ={
            source = "hashicorp/aws"
            version ="~>4.0" #ensure ~ is right
        }
    }
    backend "s3" {
      key = "aws/ec2-deploy/terraform.tfstate"
    }
}
provider "aws" {
  region = var.region
}
resource "aws_instance" "server" {
  ami = "ami-0becc523130ac9d5d" #Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  instance_type = "t3.micro"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.maingroup.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = var.private_key
    timeout = "4n"
  }  
  tags = {
    "name" = "DeployNM"
  }
}
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "EC2-ECR-AUTH" #THE ROLE NAME I CREATED ON AWS
}
resource "aws_security_group" "maingroup" {
  egress = [
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
        from_port = 0
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        protocol = "-1"
        security_groups = []
        self = false
        to_port = 0
    }
  ]
  ingress = [
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
        from_port = 22
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 22
    },
    {
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
        from_port = 80
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 80
    }
  ]
}
resource "aws_key_pair" "deployer" {
  key_name = var.key_name
  public_key = var.public_key
}
output "instance_public_ip" {
  value = aws_instance.server.public_ip
  sensitive = true
}