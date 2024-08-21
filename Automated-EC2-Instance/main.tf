terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "xxxxxx"  # add your own access key here
  secret_key = "xxxx/xxxxx"  # add your own secret key here
}

# Creation of the main vpc , #Step 1
resource "aws_vpc" "Mo_VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Automated EC2 Terraform"
  }
}

#Creating the Internet Gateway, #Step 2
resource "aws_internet_gateway" "Mo_InternetGateway" {
  vpc_id = aws_vpc.Mo_VPC.id

  tags = {
    Name = "Automated EC2 Terraform"
  }
}

resource "aws_egress_only_internet_gateway" "Mo_EgressOnlyInternetGateway" {
  vpc_id = aws_vpc.Mo_VPC.id

  tags = {
    Name = "Automated EC2 Terraform"
  }
}

#Create the route table, #Step 3
resource "aws_route_table" "Mo_RouteTable" {
  vpc_id = aws_vpc.Mo_VPC.id

  route {
    #Sending all traffic to internet gateway by setting cidr block to 0.0.0.0/0
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Mo_InternetGateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.Mo_EgressOnlyInternetGateway.id
  }

  tags = {
    Name = "Automated EC2 Terraform"
  }
}

#Create the subnet where webserver will reside, #Step 4
resource "aws_subnet" "Mo_Subnet" {
    vpc_id = aws_vpc.Mo_VPC.id
    cidr_block =  "10.0.1.0/24"
    availability_zone = "us-east-1a"
    
    tags = {
    Name = "Automated EC2 Terraform"
  }
}

#Create a route table association, #Step 5
resource "aws_route_table_association" "Mo_RouteTableAssociation" {
    subnet_id = aws_subnet.Mo_Subnet.id
    route_table_id = aws_route_table.Mo_RouteTable.id
  
  
}

#Create the AWS Security Group, #Step 6
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.Mo_VPC.id

  tags = {
    Name = "allow_web_traffic"
  }
}

# Ingress rule to allow HTTP (port 80) traffic for IPv4
resource "aws_security_group_rule" "allow_http_ipv4" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # This allows all IPv4 traffic
  security_group_id = aws_security_group.allow_web_traffic.id
}

# Ingress rule to allow HTTPS (port 443) traffic for IPv4
resource "aws_security_group_rule" "allow_https_ipv4" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # This allows all IPv4 traffic
  security_group_id = aws_security_group.allow_web_traffic.id
}

# Ingress rule to allow HTTP (port 80) traffic for IPv6
resource "aws_security_group_rule" "allow_http_ipv6" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]  # This allows all IPv6 traffic
  security_group_id = aws_security_group.allow_web_traffic.id
}

# Ingress rule to allow HTTPS (port 443) traffic for IPv6
resource "aws_security_group_rule" "allow_https_ipv6" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv6_cidr_blocks  = ["::/0"]  # This allows all IPv6 traffic
  security_group_id = aws_security_group.allow_web_traffic.id
}

# Ingress rule to allow SSH (port 22) traffic for IPv4
resource "aws_security_group_rule" "allow_ssh_ipv4" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow from anywhere, restrict as needed
  security_group_id = aws_security_group.allow_web_traffic.id
}

# Egress rule to allow all outbound traffic for IPv4
resource "aws_security_group_rule" "allow_all_outbound_ipv4" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow outbound to any IPv4 address
  security_group_id = aws_security_group.allow_web_traffic.id
}


#Create the network interface, #Step 7
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.Mo_Subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [ aws_security_group.allow_web_traffic.id ]

}

#Create the elastic IP, #Step 8
resource "aws_eip" "lb" {
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.Mo_InternetGateway ]
}

#Create the linux server, #Step 9
resource "aws_instance" "web-server-instance" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"  # Must match the AZ we setup in the Subnet
    key_name = "AutomatedEC2Project-Keypair"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id

    }

    user_data = <<-EOF
            #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'
EOF

tags = {
    Name = "Web Server!"
}
  
}