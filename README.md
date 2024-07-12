<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<h1 align="center">
  <br>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" alt="Terraform" width="200">
  <br>
  🌟 <strong>Terraform AWS WordPress Setup</strong> 🌟
  <br>
</h1>
<h4 align="center">A guide to setting up a WordPress server on AWS using Terraform!</h4>
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
<h3><strong>Create the <code>main.tf</code> File</strong></h3>
<p>First, create a file named <code>main.tf</code> in your project directory. This file will contain all the Terraform configuration needed to set up your AWS infrastructure. Let's break down what each part of the file does and why we're including it.</p>
Provider Configuration
html
Copy code
<pre><code class="hcl">
provider "aws" {
  region = "us-east-1" # This can be any AWS region you want
}
</code></pre>
<p>This block specifies the provider we are using, which is AWS in this case. The <code>region</code> attribute sets the AWS region where our resources will be created. You can change this to your preferred region.</p>
Creating a VPC (Virtual Private Cloud)
html
Copy code
<pre><code class="hcl">
resource "aws_vpc" "mo_customVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mo_CustomVPC"
  }
}
</code></pre>
<p>A VPC is a virtual network in AWS that you can use to launch your resources in a logically isolated section. The <code>cidr_block</code> attribute defines the IP address range for the VPC. Here, we are using <code>10.0.0.0/16</code> which allows for a range of IP addresses within the VPC.</p>
Creating a Subnet
html
Copy code
<pre><code class="hcl">
resource "aws_subnet" "mo_wordpressSubnet" {
  vpc_id     = aws_vpc.mo_customVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mo_wordpressSubnet"
  }
}
</code></pre>
<p>A subnet is a range of IP addresses in your VPC. In this block, we create a subnet within our VPC with the <code>cidr_block</code> of <code>10.0.1.0/24</code>. This subnet will be used to host our WordPress instance.</p>
Creating an Internet Gateway
html
Copy code
<pre><code class="hcl">
resource "aws_internet_gateway" "mo_InternetGateway" {
  vpc_id = aws_vpc.mo_customVPC.id
  tags = {
    Name = "mo_InternetGateway"
  }
}
</code></pre>
<p>An Internet Gateway is a horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. Here, we attach the internet gateway to our VPC.</p>
Creating a Route Table and Association
html
Copy code
<pre><code class="hcl">
resource "aws_route_table" "mo_routeTable" {
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
}
</code></pre>
<p>The route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed. We create a route table and associate it with our subnet to route traffic to the internet through the internet gateway.</p>
Creating an EC2 Instance
html
Copy code
<pre><code class="hcl">
resource "aws_instance" "wordpress" {
  ami           = "ami-0eaf7c3456e7b5b68"  # This is based on your selected region. For example: us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mo_wordpressSubnet.id
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
}
</code></pre>
<p>An EC2 instance is a virtual server in AWS. Here, we define an instance with a specified Amazon Machine Image (AMI) and instance type. The <code>user_data</code> script contains commands that will run when the instance starts, setting up a LAMP stack (Linux, Apache, MySQL, PHP) and installing WordPress.</p>
<p><strong>Note:</strong> Replace the security group ID with your actual security group ID.</p>
Applying the Terraform Configuration
<p>After setting up your <code>main.tf</code> file, run the following command to create the resources defined in the configuration file:</p>
<pre><code>terraform apply</code></pre>
<p>Confirm the action by typing <code>yes</code> when prompted.</p>
<h3><strong>Start and Enable Nginx</strong></h3>
<p>After installing Nginx, start and enable it to ensure it runs automatically on system boot.</p>
<pre><code>sudo systemctl start nginx
sudo systemctl enable nginx
</code></pre>

<h3><strong>Configure Nginx</strong></h3>
<p>Adjust the default server block configuration to point to your WordPress directory.</p>
<ul>
  <li>Open the default Nginx configuration file for editing:</li>
</ul>
<pre><code>sudo nano /etc/nginx/sites-available/default
</code></pre>

<p>Update the <code>root</code> directive to point to your WordPress directory:</p>
<pre><code>server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html/wordpress;  # Adjust path as needed

    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;  # Adjust PHP version if necessary
    }
}
</code></pre>

<h3><strong>Test Nginx Configuration</strong></h3>
<p>Check if the configuration file syntax is correct.</p>
<pre><code>sudo nginx -t
</code></pre>

<p>If the test is successful, reload Nginx to apply the changes.</p>
<pre><code>sudo systemctl reload nginx
</code></pre>

<h2 id="setting-up-mariadb"><strong>Setting Up MariaDB</strong></h2>
<h3><strong>Install MariaDB</strong></h3>
<p>Use the package manager to install MariaDB.</p>
<pre><code>sudo apt update
sudo apt install mariadb-server
</code></pre>

<h3><strong>Start and Enable MariaDB</strong></h3>
<p>Start and enable MariaDB to ensure it runs automatically on system boot.</p>
<pre><code>sudo systemctl start mariadb
sudo systemctl enable mariadb
</code></pre>

<h3><strong>Secure MariaDB</strong></h3>
<p>Run the included security script to remove insecure default settings and ensure the installation is secure.</p>
<pre><code>sudo mysql_secure_installation
</code></pre>

<h3><strong>Create a Database for WordPress</strong></h3>
<p>Log in to the MariaDB shell and create a database and user for WordPress.</p>
<pre><code>sudo mysql -u root -p
</code></pre>

<p>Once logged in, run the following SQL commands:</p>
<pre><code>CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
</code></pre>

<h2 id="configuring-wordpress"><strong>Configuring WordPress 🛠️</strong></h2>
<h3><strong>Set Up WordPress</strong></h3>
<ul>
  <li>Navigate to your WordPress directory:</li>
</ul>
<pre><code>cd /var/www/html/wordpress
</code></pre>

<ul>
  <li>Create a copy of the sample configuration file:</li>
</ul>
<pre><code>cp wp-config-sample.php wp-config.php
</code></pre>

<ul>
  <li>Edit the configuration file to add your database information:</li>
</ul>
<pre><code>sudo nano wp-config.php
</code></pre>

<ul>
  <li>Update the following lines with your database details:</li>
</ul>
<pre><code>define('DB_NAME', 'wordpress');
define('DB_USER', 'wp_user');
define('DB_PASSWORD', 'password');
define('DB_HOST', 'localhost');
</code></pre>

<h2 id="accessing-wordpress"><strong>Accessing WordPress 🌐</strong></h2>
<p>Open a web browser and navigate to your server's IP address to complete the WordPress setup through the web interface.</p>

<h2 id="contributing"><strong>Contributing 🤝</strong></h2>
<p>Contributions are welcome! Please feel free to submit a Pull Request.</p>

<p align="center">
  <a href="https://medium.com/@sayedsylvainltd" target="_blank">Medium</a> |
  <a href="https://www.linkedin.com/in/mohammed-sayed-16112a179/" target="_blank">LinkedIn</a> |
  <a href="https://github.com/Mo-ASayed" target="_blank">GitHub</a>
</p>
</body>
</html>
