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
<p>Create a file named <code>main.tf</code> in your project directory and add the following configuration:</p>
<pre><code class="hcl">provider "aws" {
  region = "us-east-1" # This can be any location you want
}

resource "aws_vpc" "mo_customVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mo_CustomVPC"
  }
}

resource "aws_subnet" "mo_wordpressSubnet" {
  vpc_id     = aws_vpc.mo_customVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "mo_wordpressSubnet"
  }
}

resource "aws_internet_gateway" "mo_InternetGateway" {
  vpc_id = aws_vpc.mo_customVPC.id
  tags = {
    Name = "mo_InternetGateway"
  }
}

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

resource "aws_instance" "wordpress" {
  ami           = "ami-0eaf7c3456e7b5b68"  # This is based on your selected region. for example: us-east-1
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

<h3><strong>Apply the Terraform Configuration</strong></h3>
<p>Run <code>terraform apply</code> to create the resources defined in the configuration files. Confirm the action by typing <code>yes</code> when prompted.</p>

<h2 id="setting-up-nginx"><strong>Setting Up Nginx</strong></h2>
<h3><strong>Install Nginx</strong></h3>
<p>Use the package manager to install Nginx.</p>
<pre><code>sudo apt update
sudo apt install nginx
</code></pre>

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
<h3><strong>Installation</strong></h3>
<p>Use the package manager to install MariaDB.</p>
<pre><code>sudo apt install mariadb-server
</code></pre>

<h3><strong>Start and Enable MariaDB</strong></h3>
<p>After installation, start and enable MariaDB to run on system boot.</p>
<pre><code>sudo systemctl start mariadb
sudo systemctl enable mariadb
</code></pre>

<h3><strong>Secure Installation</strong></h3>
<p>Run the MySQL secure installation script to set a root password and improve security.</p>
<pre><code>sudo mysql_secure_installation
</code></pre>

<p>Follow the prompts to set up the root password and secure MariaDB.</p>

<h3><strong>Create Database and User for WordPress</strong></h3>
<p>Log in to MySQL with the root account.</p>
<pre><code>sudo mysql -u root -p
</code></pre>

<p>Enter the root password when prompted.</p>
<p>Execute the following SQL commands to create a database and user for WordPress. Replace <code>wordpress</code>, <code>wordpressuser</code>, and <code>password</code> with your preferred database name, username, and password.</p>
<pre><code>CREATE DATABASE wordpress;
CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
</code></pre>

<h2 id="setting-up-wordpress"><strong>Setting Up WordPress</strong></h2>
<h3><strong>Installation</strong></h3>
<p>Download and extract the latest WordPress package into your web directory.</p>
<pre><code>cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
sudo mv wordpress /var/www/html/
</code></pre>

<h3><strong>Set Permissions</strong></h3>
<p>Adjust permissions for WordPress to function correctly. *We set the file permissions to 644, This is because we need the wordpress files to be readable by the web server.
</p>
<pre><code>sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
*sudo find /var/www/html/wordpress -type f -exec chmod 644 {} \;
</code></pre>

<h3><strong>Configuration</strong></h3>
<p>Navigate to your WordPress directory and rename the sample configuration file.</p>
<pre><code>cd /var/www/html/wordpress
cp wp-config-sample.php wp-config.php
nano wp-config.php
</code></pre>

<p>Update the database details (<code>DB_NAME</code>, <code>DB_USER</code>, <code>DB_PASSWORD</code>, <code>DB_HOST</code>) with the values you set in MariaDB.</p>
<pre><code>define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wordpressuser' );
define( 'DB_PASSWORD', 'password' );
define( 'DB_HOST', 'localhost' );
</code></pre>

<h3><strong>Complete WordPress Installation</strong></h3>
<p>Open a web browser and navigate to your server's IP address or domain name. Follow the WordPress installation prompts to set up your site.</p>

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
