provider "aws" {
  region = "us-east-1"
}

# VPC Modülü
module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
  private_subnet = "10.0.2.0/24"
  db_subnet     = "10.0.3.0/24"
}

# NAT Gateway (Private Subnet'in internete erişimi için)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.vpc.public_subnet_id
}

# Elastic IP NAT Gateway için
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Güvenlik Grupları (Frontend için)
resource "aws_security_group" "frontend_sg" {
  name        = "frontend_security_group"
  description = "React uygulaması için trafik"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP trafiğine izin veriyoruz
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Güvenlik Grupları (Backend için)
resource "aws_security_group" "backend_sg" {
  name        = "backend_security_group"
  description = "Node.js backend API için trafik"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Frontend'den gelen API çağrılarına izin veriyoruz
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Public Subnet'teki EC2 Instance (React Frontend)
resource "aws_instance" "frontend" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_id
  security_groups = [aws_security_group.frontend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nodejs npm git
    git clone https://github.com/kullanici/react-uygulamasi.git /home/ec2-user/react-uygulamasi
    cd /home/ec2-user/react-uygulamasi
    npm install
    npm start -- --host 0.0.0.0
  EOF

  tags = {
    Name = "React-Frontend"
  }
}

# Private Subnet'teki EC2 Instance (Node.js Backend)
resource "aws_instance" "backend" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnet_id
  security_groups = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nodejs npm git
    git clone https://github.com/kullanici/nodejs-backend.git /home/ec2-user/nodejs-backend
    cd /home/ec2-user/nodejs-backend
    npm install
    node index.js
  EOF

  tags = {
    Name = "Nodejs-Backend"
  }
}

# RDS için güvenlik grubu (Backend'e erişim izni)
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "RDS için güvenlik grubu"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Backend'ten gelen MySQL trafiğine izin veriyoruz
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS (MySQL)
module "rds" {
  source              = "./modules/rds"
  db_subnet_group     = module.vpc.db_subnet_id
  allocated_storage   = 20
  instance_class      = "db.t2.micro"
  engine              = "mysql"
  username            = "admin"
  password            = "password123"
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
