provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mo_customVPC"
  }
}
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mo_wordpressSubnet"
  }
}
resource "aws_instance" "wordpress" {
  ami           = "ami-0eaf7c3456e7b5b68" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  associate_public_ip_address = true  # Ensure this is set to true

  tags = {
    Name = "Mo WordPress Server"
  }
}

