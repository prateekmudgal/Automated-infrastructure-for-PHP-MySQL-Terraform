# Deploy PHP Application with MySQL Database using Terraform

## Project Overview

This project demonstrates the deployment of a PHP application with a MySQL database using Terraform. The infrastructure setup includes creating a Virtual Private Cloud (VPC) with 256 IPs, consisting of two subnets: a public subnet with 128 IPs and a private subnet with 64 IPs. The public subnet is used for hosting the PHP application, while the private subnet is reserved for the MySQL database. The PHP application includes a login and signup page for user authentication.

## Technologies Used

- **Terraform**: Infrastructure as Code (IaC) tool for provisioning and managing cloud resources.
- **AWS**: Cloud provider for hosting and managing infrastructure.
- **Ubuntu**: Operating system for EC2 instances.
- **PHP**: Server-side scripting language.
- **MySQL**: Relational database management system.
- **Nginx**: Web server for serving PHP applications.

## Prerequisites

Ensure you have the following installed and configured:

- Terraform v1.0 
- AWS CLI
- A valid AWS account

## Terraform Configuration

This section provides an overview of the Terraform resources and their configurations used in this project.

### 1. AWS Provider Configuration

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "cloudguru"
}
```

- **Region**: `us-east-1` - AWS region where resources will be created.
- **Profile**: `cloudguru` - AWS CLI profile for credentials.

### 2. VPC and Subnets

#### VPC

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "my_vpc"
  }
}
```

- **CIDR Block**: `10.0.0.0/24` - Defines the IP address range for the VPC.

#### Public Subnet

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/25"

  tags = {
    Name = "public_subnet",
    env  = "test"
  }
}
```

- **CIDR Block**: `10.0.0.0/25` - 128 IPs for the public subnet.

#### Private Subnet

```hcl
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.128/26"

  tags = {
    Name = "private_subnet",
    env  = "test"
  }
}
```

- **CIDR Block**: `10.0.0.128/26` - 64 IPs for the private subnet.

### 3. Internet and NAT Gateway

#### Internet Gateway

```hcl
resource "aws_internet_gateway" "gate_way" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_internet_gateway"
  }
}
```

- **Purpose**: Provides internet access to resources in the public subnet.

#### NAT Gateway

```hcl
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gate_way]
}
```

- **Purpose**: Allows resources in the private subnet to access the internet while remaining inaccessible from the internet.

### 4. Route Tables

#### Route Table for Public Subnet

```hcl
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gate_way.id
  }

  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
```

- **Purpose**: Routes internet-bound traffic from the public subnet through the internet gateway.

### 5. Security Groups

#### Public Security Group

```hcl
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "public_sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- **Purpose**: Allows HTTP (80), HTTPS (443), and SSH (22) access to the instances in the public subnet.

#### Private Security Group

```hcl
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "private_sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

- **Purpose**: Allows MySQL (3306) access from the public subnet and SSH (22) access.

### 6. Key Pair

```hcl
resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV6l2dXhjQgFqa7PzLFgEiZQe+knlfC+LHDfzU0s65QB6aJXF72VHKDv46WNldFX6WTRS+oJq7j5varuP6xa5/gd5aMn/LLWemn9QAaW3bIt7x8Np2e3Pj0SpjDmGCIQKlq99TXlwd4iRXjDiU6Q+OUwxDe4yxTB8K/mNJLV54jiUfqrPRwKRsu7Gyy0ewwONKsgsZmiMb6dTyLgK5hth9zQvb8BVtW6hxsDWok/e3eLl3sGD2+3uJ4oIpnjgi2kjdAJsjp0FQyrMV0mngqxntRibnlzAlJ1IBybWwwWHUjBLeLP6H6meTuOxs5WHT3OBkmNXXjUFLIL57gY2NfOfSYhZHPOM28hDwDh1yfKLDt55Eb8yiGZSJwDBIjyDkHhrqjo2juEMQLVqdeRb28Wi/8KEOSGxyvEPmmf9H8S2T1bduIcbxOqMfyZrSFWbrsJLps7FBnNlrwla0sccHVS2Gxs1CejdIsji9ONMip+To0RKXNTHxnCm7mxLTdWp7kVU= this pc@DESKTOP-4A5EI2E"
}   #this key you can generate in your local or ec2 instance
```

- **Purpose**: Provides SSH access to the EC2 instances.

### 7. EC2 Instances

#### Frontend Instance

```hcl
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
```

- **Purpose**: Hosts the PHP application in the public subnet with a public IP.

#### Backend Instance

```hcl
resource "aws_instance" "backend" {
  ami                         = data.aws_

ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = "my_key"
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "backend"
  }
}
```

- **Purpose**: Hosts the MySQL database in the private subnet without a public IP.

### 8. AMI for Ubuntu

```hcl
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
```

- **Purpose**: Selects the most recent Ubuntu AMI for EC2 instances.

## Nginx Configuration

The `nginx.conf` file is configured to serve a PHP application and handle requests:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    client_max_body_size 128M;

    root /home/ubuntu/php-basic-login-signup-with-mysq;

    index index.php index.html index.htm index.nginx-debian.html; #edit the default file and add index.php 

    server_name 3.89.209.69;   #server IP 

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

- **Listening Ports**: Listens on port 80 for HTTP traffic.
- **Client Max Body Size**: Configured to allow uploads up to 128MB.
- **Root Directory**: Specifies the root directory for the application.
- **Index Files**: Defines the order of index files.
- **Server Name**: Set to the public IP of the instance.
- **Location / Block**: Tries to serve files or directories; returns a 404 error if not found.
- **Location ~ \.php$ Block**: Passes PHP requests to the FastCGI server.
- **Location ~ /\.ht Block**: Denies access to `.htaccess` files.

## Installation and Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/prateekmudgal/terraform-vpc-aws-php-mysql.git
```

### Step 2: Initialize Terraform

Initialize Terraform and install the required providers:

```bash
terraform init
```

### Step 3: Configure AWS Credentials

Ensure your AWS credentials are configured:

```bash
aws configure
```

Provide your AWS Access Key, Secret Key, region, and output format as prompted.

### Step 4: Plan and Apply Terraform Configuration

To create the infrastructure, execute the following commands:

```bash
terraform plan
terraform apply
```

Review the planned changes and confirm the apply process.

### Step 5: Access the Instances

- **Frontend Instance**: Access the PHP application using the public IP address assigned to this instance.
- **Backend Instance**: Access the MySQL database from the frontend instance using internal networking.
  

## Usage
![Screenshot (233)](https://github.com/user-attachments/assets/c17e768c-4550-4fac-b1a4-ac3d009e2d6a)

Deploy your PHP application on the frontend instance and configure it to connect to the MySQL database on the backend instance. Use the security group settings to control access to your application and database.

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Submit a pull request.

I hope you find it useful. If you have any doubt in any of the step then feel free to contact me. If you find any issue in it then let me know.

<table>
  <tr>
    <th><a href="https://www.linkedin.com/in/prateek-mudgal-devops" target="_blank"><img src="https://img.icons8.com/color/452/linkedin.png" alt="linkedin" width="30"/></a></th>
    <th><a href="mailto:mudgalprateek00@gmail.com" target="_blank"><img src="https://img.icons8.com/color/344/gmail-new.png" alt="Mail" width="30"/></a></th>
  </tr>
</table>


Feel free to adjust or expand the content as needed!
