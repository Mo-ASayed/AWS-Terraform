variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "mo_nginx-ec2-vpc" {
  cidr_block = "10.0.0.0/16"  # Larger CIDR block for VPC
  tags = {
    Name = "mo-nginx-ec2-vpc"
  }
}

resource "aws_subnet" "mo_nginx-ec2-subnet" {
  vpc_id     = aws_vpc.mo_nginx-ec2-vpc.id
  cidr_block = "10.0.1.0/24"  # Subnet within the VPC CIDR block
  tags = {
    Name = "mo-nginx-ec2-subnet"
  }
}

resource "aws_instance" "NGINX-EC2" {
  ami           = "ami-0eaf7c3456e7b5b68" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mo_nginx-ec2-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.mo_nginx-ec2-security_group_allow_http.id]
  key_name = var.key_name  
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF
  tags = {
    Name = "Mo-NGINX-EC2"
  }
}

resource "aws_security_group" "mo_nginx-ec2-security_group_allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.mo_nginx-ec2-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mo-nginx-ec2-allow_http"
  }
}

resource "aws_internet_gateway" "mo_nginx-ec2-igw" {
  vpc_id = aws_vpc.mo_nginx-ec2-vpc.id
}

resource "aws_route_table" "mo_nginx-ec2-route_table" {
  vpc_id = aws_vpc.mo_nginx-ec2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mo_nginx-ec2-igw.id
  }

  tags = {
    Name = "mo-nginx-ec2-route_table"
  }
}

resource "aws_route_table_association" "mo_nginx-ec2-subnet_association" {
  subnet_id      = aws_subnet.mo_nginx-ec2-subnet.id
  route_table_id = aws_route_table.mo_nginx-ec2-route_table.id
}
