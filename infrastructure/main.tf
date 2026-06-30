# FREE TIER ONLY - t2.micro EC2, no load balancers, no NAT gateways

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# ==============================================================================
# DATA SOURCE: Fetch latest Ubuntu 22.04 LTS AMI automatically
# ==============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical owner ID
}

# ==============================================================================
# NETWORK RESOURCES: Custom VPC (Saves cost & teaches isolation)
# ==============================================================================
# Note: Using a custom VPC is highly recommended for learning projects. 
# It provides isolation and teaches how CIDR blocks, Subnets, and Route Tables 
# connect under the hood, whereas the Default VPC hides these concepts.
resource "aws_vpc" "technova_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "technova-vpc"
  }
}

resource "aws_subnet" "technova_subnet" {
  vpc_id                  = aws_vpc.technova_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "technova-public-subnet"
  }
}

resource "aws_internet_gateway" "technova_igw" {
  vpc_id = aws_vpc.technova_vpc.id

  tags = {
    Name = "technova-igw"
  }
}

resource "aws_route_table" "technova_route_table" {
  vpc_id = aws_vpc.technova_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.technova_igw.id
  }

  tags = {
    Name = "technova-public-rt"
  }
}

resource "aws_route_table_association" "technova_rta" {
  subnet_id      = aws_subnet.technova_subnet.id
  route_table_id = aws_route_table.technova_route_table.id
}

# ==============================================================================
# SECURITY GROUP: Firewall Rules
# ==============================================================================
resource "aws_security_group" "technova_sg" {
  name        = "technova-sg"
  description = "Allow inbound SSH and Flask web application traffic"
  vpc_id      = aws_vpc.technova_vpc.id

  # Inbound Rule: SSH port 22 for administration
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: Flask Application Port 5000
  ingress {
    description = "Allow Flask app traffic from anywhere"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule: Allow all traffic out to the internet
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "technova-sg"
  }
}

# ==============================================================================
# SSH KEY PAIR: Upload generated public key to AWS
# ==============================================================================
resource "aws_key_pair" "technova_key" {
  key_name   = "technova-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# ==============================================================================
# COMPUTE RESOURCE: EC2 Instance
# ==============================================================================
resource "aws_instance" "technova_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro" # FREE TIER ONLY — DO NOT CHANGE
  subnet_id                   = aws_subnet.technova_subnet.id
  vpc_security_group_ids      = [aws_security_group.technova_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.technova_key.key_name

  # Provision script to run on instance first boot: installs Docker Engine
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
              mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "technova-app-server"
  }
}
