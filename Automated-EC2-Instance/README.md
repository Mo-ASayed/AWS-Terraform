# This is the steps we are taking to automate a complete EC2 instance creation, including the creation of the VPC

# Step 1: Create the VPC
# Step 2: Create the Internet Gateway
# Step 3: Create a Custom Route Table
# Step 4: Create a subnet
# Step 5: Associate the subnet with route table
# Step 6: Create Security Group to allow ports 22,80,443
# Step 7: Create a network interface with an IP in the subnet that was create in step 4
# Step 8: Assign an elastic IP to the network interface created in step 7
# Step 9: Create ubuntu Server and install/enable apache2