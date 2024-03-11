terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/**
* Create a new RDS instance
*/
resource "aws_db_instance" "main" {
  allocated_storage = 10
  db_name           = "mydb"
  identifier        = "mydb-instance"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  username          = "adminUser"
  password          = "adminPass"

  // connect to the VPC
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = true
  depends_on             = [aws_internet_gateway.igw]

  // backups
  backup_retention_period = 3
  backup_window           = "03:00-06:00"
  maintenance_window      = "sun:10:20-sun:10:50"

}

/**
* Create a new VPC Network
*/
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_eip" "db_eip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "secondary" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.main.id, aws_subnet.secondary.id]
}

resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow DB inbound traffic"
  vpc_id      = aws_vpc.main.id

  // allow traffic from any IP address
  // to the database on port 5432
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
