#
# Provider Configuration
#
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#
# Constants and Variables
#
locals {
  vpc_cidr = "10.0.0.0/16" // IP range for whole network
  azs = ["us-east-1a", "us-east-1b"] // Two Availability Zones
  # Tags used for tracking and keeping everything organized
  common_tags = {
    Project = "Secure-Multi-Tier-VPC"
    Owner = "admin"
  }
}

#
# Network Foundation
#
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(local.common_tags, {Name = "production-vpc"})
}

# Allows for communication between VPC and internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {Name = "production-igw"})
}

#
# Subnet Creation
#
// Tier 1: Public Subnets (Load Balancers, NAT Gateways, Bastion)
resource "aws_subnet" "public" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index) // Adds 8 bits to netmask(10.0.0.0/24, 10.0.1.0/24)
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true // Public IP
  tags = merge(local.common_tags, {Name = "public-subnet-${count.index + 1}"})
}

# Tier 2: Private Subnets (App Servers)
resource "aws_subnet" "private_app" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index + 2) # 10.0.2.0/24, 10.0.3.0/24
  availability_zone = local.azs[count.index]
  tags = merge(local.common_tags, {Name = "private-subnet-${count.index + 1}"})
}

# Tier 3: Private Subnets (For Databases)
resource "aws_subnet" "private_data" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(local.vpc_cidr, 8, count.index + 4) # 10.0.4.0/24, 10.0.5.0/24
  availability_zone = local.azs[count.index]
  tags = merge(local.common_tags, {Name = "private-data-subnet-${count.index + 1}"})
}

#
# Outbound Connection
#
// Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count = length(local.azs)
  domain = "vpc"
  tags = merge(local.common_tags, {Name = "elastic-ip-${count.index + 1}"})
}

# NAT Gateways placed in the Public subnet to reach the IGW
resource "aws_nat_gateway" "nat" {
  count = length(local.azs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  tags = merge(local.common_tags, {Name = "nat-gw-${count.index + 1}"})
  depends_on = [aws_internet_gateway.igw] // Safety instruction that only builds NAT Gateway after IGW is created
}

#
# Route Tables
#
// Public Route Table: Routes 0.0.0.0/0 to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, {Name = "public-route"})
}

resource "aws_route_table_association" "public" {
  count = length(local.azs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table: Routes 0.0.0.0/0 to NAT Gateway
resource "aws_route_table" "private_app" {
  count = length(local.azs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(local.common_tags, {Name = "private-app-route-${count.index + 1}"})
}

resource "aws_route_table_association" "private_app" {
  count = length(local.azs)
  subnet_id = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private Data Route Table: No route to internet
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id
  # No route to 0.0.0.0/0
  tags = merge(local.common_tags, {Name = "private-data-route"})
}

resource "aws_route_table_association" "private_data" {
  count = length(local.azs)
  subnet_id = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
}

#
# Security Groups
#
// Bastion SG: Entry for admins
resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id = aws_vpc.main.id

# Only login from admin IP
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["96.250.8.229/32"] # Update to add you IP
  }
# Outbound: Allow all traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {Name = "bastion-sg"})
}

# Load Balancer SG: Entry for web traffic
resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "Security group for Public Load Balancer"
  vpc_id = aws_vpc.main.id

# Inbound: Allow HTTPS from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App Tier SG: Accepts traffic only from ALB and Bastion
resource "aws_security_group" "app_sg" {
  name = "app-sg"
  description = "Security group for App Tier"
  vpc_id = aws_vpc.main.id

  # Inbound: Allow traffic only from Load Balancer
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Allow SSH from only Bastion Host
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data Tier SG: Accepts traffic only from App Tier
resource "aws_security_group" "data_sg" {
  name = "data-sg"
  description = "Security group for Data Tier"
  vpc_id = aws_vpc.main.id

  # Inbound: Allow Database traffic from App Servers
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  tags = merge(local.common_tags, {Name = "data-sg"})
}

# 
# Network ACLs
#
// Public NACL: Allow internet traffic
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # Allow HTTP/HTTPS from Internet
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 443
  }
  
  # Allow login from admin IP
  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "96.250.8.229/32"
    from_port = 22
    to_port = 22
  }

  # Allow return traffic
  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags = merge(local.common_tags, {Name = "public-nacl"})
}

# Private NACL: Isolation for App and Data subnets
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id
  subnet_ids = concat(aws_subnet.private_app[*].id, aws_subnet.private_data[*].id)

  # Allow internal VPC communication
  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = local.vpc_cidr
    from_port = 0
    to_port = 0
  }

  # Allow return traffic from internet 
  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags = merge(local.common_tags, {Name = "private-nacl"})
}

# Bastion Host
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023.*-x86_64"] 
  }
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  key_name = "project-key" // This project key should be created in AWS console
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  
  # Script to install updates on first boot
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF
  tags = merge(local.common_tags, {Name = "Bastion-Host"})
}

output "vpc_id" {
  value = aws_vpc.main.id // The ID of the VPC
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip // Public IP of the Bastion Host login
}