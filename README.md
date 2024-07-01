</head>
<body>

<h1 align="center">
  <br>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" alt="Terraform" width="200">
  <br>
  🌟 <strong>Terraform AWS WordPress Setup</strong> 🌟
  <br>
</h1>
<h4 align="center">A guide to setting up a WordPress server on AWS using Terraform!.</h4>
<p align="center">
  <a href="https://www.terraform.io">
    <img src="https://img.shields.io/badge/Terraform-v1.0.0-blue" alt="Terraform Version">
  </a>
  <a href="https://aws.amazon.com">
    <img src="https://img.shields.io/badge/AWS-WordPress-orange" alt="AWS WordPress">
  </a>
  <a href="https://www.terraform.io/docs/providers/aws/index.html">
    <img src="https://img.shields.io/badge/AWS-Provider-brightgreen" alt="AWS Provider">
  </a>
</p>
<p align="center">
  <a href="#what-is-terraform"><strong>What is Terraform? 🤔</strong></a> •
  <a href="#why-use-terraform"><strong>Why Use Terraform? 🚀</strong></a> •
  <a href="#setting-up-terraform"><strong>Setting Up Terraform ⚙️</strong></a> •
  <a href="#creating-aws-infrastructure-with-terraform"><strong>Creating AWS Infrastructure with Terraform 🌐</strong></a> •
  <a href="#accessing-wordpress"><strong>Accessing WordPress 🌐</strong></a> •
  <a href="#additional-resources"><strong>Additional Resources 📚</strong></a>
</p>

<h2 id="what-is-terraform"><strong>What is Terraform? 🤔</strong></h2>
<p><strong>Terraform</strong> is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure resources like virtual machines, networks, and containers using configuration files. These files describe the desired state of your infrastructure, and Terraform automatically manages and provisions the necessary resources to match that state. This approach simplifies and automates the provisioning and management of cloud infrastructure, providing a consistent workflow to deploy and update infrastructure across various cloud providers like AWS, Azure, Google Cloud, and more, as well as on-premises environments.</p>

<h2 id="why-use-terraform"><strong>Why Use Terraform? 🚀</strong></h2>
<ul>
  <li><strong>Automation</strong>: Automates the provisioning and management of cloud resources.</li>
  <li><strong>Consistency</strong>: Ensures consistent infrastructure deployment across different environments.</li>
  <li><strong>Version Control</strong>: Integration with version control systems like Git for tracking changes and collaboration.</li>
  <li><strong>Scalability</strong>: Easily scale infrastructure by modifying configuration files and applying the changes.</li>
  <li><strong>Modularity</strong>: Promotes reuse of code with modules, simplifying the management of complex infrastructure setups.</li>
</ul>

<h2 id="setting-up-terraform"><strong>Setting Up Terraform ⚙️</strong></h2>
<h3><strong>Prerequisites</strong></h3>
<ul>
  <li>An AWS account</li>
  <li>Terraform installed on your local machine</li>
  <li>AWS CLI configured with your credentials</li>
</ul>

<h3><strong>Steps to Set Up Terraform</strong></h3>
<h4><strong>Install Terraform</strong></h4>
<p>Download and install Terraform from <a href="https://www.terraform.io/downloads">HashiCorp's website</a>.</p>
<h4><strong>Configure AWS CLI</strong></h4>
<p>Configure the AWS CLI with your credentials by running:</p>
<pre><code>aws configure</code></pre>
<p>Provide your AWS Access Key ID, Secret Access Key, region, and output format.</p>
<h4><strong>Initialise a Terraform Project</strong></h4>
<p>Create a directory for your Terraform project and navigate into it. Run:</p>
<pre><code>terraform init</code></pre>
<p>to initialise the project.</p>

<h2 id="creating-aws-infrastructure-with-terraform"><strong>Creating AWS Infrastructure with Terraform 🌐</strong></h2>
<h3><strong>Provider Configuration</strong></h3>
<p>Configure the AWS provider with the specified region:</p>
<pre><code class="hcl">provider "aws" {
  region = "us-east-1" #This can be any location you want
}</code></pre>

<h3><strong>Create a VPC</strong></h3>
<p>Create a Virtual Private Cloud (VPC) with a specified CIDR block:</p>
<pre><code class="hcl">resource "aws_vpc" "mo_customVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mo_CustomVPC"
  }
}</code></pre>

<h3><strong>Create a Subnet</strong></h3>
<p>Create a subnet within the VPC:</p>
<pre><code class="hcl">resource "aws_subnet" "mo_wordpressSubnet" {
  vpc_id     = aws_vpc.mo_customVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mo_wordpressSubnet"
  }
}</code></pre>

<h3><strong>Create an Internet Gateway</strong></h3>
<p>Create an Internet Gateway for internet access:</p>
<pre><code class="hcl">resource "aws_internet_gateway" "mo_InternetGateway" {
  vpc_id = aws_vpc.mo_customVPC.id
  tags = {
    Name = "mo_InternetGateway"
  }
}</code></pre>

<h3><strong>Create a Route Table</strong></h3>
<p>Create a route table to direct internet traffic from the subnet to the Internet Gateway:</p>
<pre><code class="hcl">resource "aws_route_table" "mo_routeTable" {
  vpc_id = aws_vpc.mo_customVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mo_InternetGateway.id
  }
  tags = {
    Name = "mo_RouteTable"
  }
}

resource "aws_route_table_association" "mo_routeTableAssociation" {
  subnet_id      = aws_subnet.mo_wordpressSubnet.id
  route_table_id = aws_route_table.mo_routeTable.id
}</code></pre>

<h3><strong>Launch an EC2 Instance</strong></h3>
<p>Follow the steps below to launch an EC2 instance and run a script to set up a WordPress server:</p>
<pre><code class="hcl">resource "aws_instance" "wordpress" {
  ami           = "ami-0eaf7c3456e7b5b68"  # This is based on your selected region. for example: us-east-1
  instance_type = "t2.micro"
  subnet_id     = "subnet-07359f796bd0b9ed8"  # mo_wordpressSubnet 
  security_groups = ["sg-0c7f3e0b123456789"]  # Replace with your actual security group ID

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
    yum install -y httpd mariadb-server
    systemctl start httpd
    systemctl enable httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    chown -R apache /var/www/html/*
  EOF

  tags = {
    Name = "WordPress Server"
  }
</code></pre>

<h3><strong>Applying the Configuration</strong></h3>
<p>Run <code>terraform apply</code> to create the resources defined in the configuration files. Confirm the action by typing <code>yes</code> when prompted.</p>

<h2 id="accessing-wordpress"><strong>Accessing WordPress 🌐</strong></h2>
<h4><strong>Allocate and Associate an Elastic IP</strong></h4>
<p>Allocate an Elastic IP address and associate it with your EC2 instance to provide a static public IP address.</p>
<h4><strong>Update Security Group Rules</strong></h4>
<p>Ensure that your security group allows HTTP (port 80) and SSH (port 22) traffic from the internet.</p>
<h4><strong>Connect to WordPress</strong></h4>
<p>Access your WordPress setup by navigating to the public IP address of your EC2 instance in a web browser. Complete the WordPress setup by providing database details.</p>

<h2 id="additional-resources"><strong>Additional Resources 📚</strong></h2>
<ul>
  <li><a href="https://www.terraform.io/docs">Terraform Documentation</a></li>
  <li><a href="https://docs.aws.amazon.com">AWS Documentation</a></li>
</ul>

<p align="center">
  <a href="https://www.linkedin.com/in/mohammed-sayed-16112a179/" style="text-decoration:none; color:#0e76a8;">
    <img src="https://cdn-icons-png.flaticon.com/512/174/174857.png" alt="LinkedIn" width="20" height="20"/> LinkedIn
  </a> &nbsp;&middot;&nbsp;
  <a href="https://github.com/Mo-ASayed" style="text-decoration:none; color:#333;">
    <img src="https://cdn-icons-png.flaticon.com/512/733/733609.png" alt="GitHub" width="20" height="20"/> GitHub
  </a> &nbsp;&middot;&nbsp;
  <a href="https://medium.com/@sayedsylvainltd" style="text-decoration:none; color:#00ab6c;">
    <img src="https://cdn-icons-png.flaticon.com/512/2111/2111505.png" alt="Medium" width="20" height="20"/> Medium
  </a>
</p>

</body>
</html>
