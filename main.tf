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
  region  = "us-east-1"
  profile = "cloudguru"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "my_vpc"
  }

}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/25"

  tags = {
    Name = "public_subnet",
    env  = "test"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.128/26"

  tags = {
    Name = "private_subnet",
    env  = "test"
  }
}
resource "aws_internet_gateway" "gate_way" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_internet_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gate_way.id
  }

  #   route {
  #     ipv6_cidr_block        = "::/0"
  #     egress_only_gateway_id = aws_egress_only_internet_gateway.gate_way.id
  #   }

  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}




resource "aws_eip" "ip" {

}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gate_way]
}


# Create security group for public subnet
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "public_sg"

  # Ingress rule for HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for private subnet
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "private_sg"

  # Ingress rule for MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }

  # Ingress rule for ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV6l2dXhjQgFqa7PzLFgEiZQe+knlfC+LHDfzU0s65QB6aJXF72VHKDv46WNldFX6WTRS+oJq7j5varuP6xa5/gd5aMn/LLWemn9QAaW3bIt7x8Np2e3Pj0SpjDmGCIQKlq99TXlwd4iRXjDiU6Q+OUwxDe4yxTB8K/mNJLV54jiUfqrPRwKRsu7Gyy0ewwONKsgsZmiMb6dTyLgK5hth9zQvb8BVtW6hxsDWok/e3eLl3sGD2+3uJ4oIpnjgi2kjdAJsjp0FQyrMV0mngqxntRibnlzAlJ1IBybWwwWHUjBLeLP6H6meTuOxs5WHT3OBkmNXXjUFLIL57gY2NfOfSYhZHPOM28hDwDh1yfKLDt55Eb8yiGZSJwDBIjyDkHhrqjo2juEMQLVqdeRb28Wi/8KEOSGxyvEPmmf9H8S2T1bduIcbxOqMfyZrSFWbrsJLps7FBnNlrwla0sccHVS2Gxs1CejdIsji9ONMip+To0RKXNTHxnCm7mxLTdWp7kVU= this pc@DESKTOP-4A5EI2E"
}


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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = "my_key"
  security_groups             = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = "my_key"
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "backend"
  }
}





