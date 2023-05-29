# Configuramos el proveedor de AWS para Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configuramos el provider AWS para Terraform
provider "aws" {
  region = "us-east-1"
}

# Creamos el security group para el ALB
resource "aws_security_group" "alb_sg" {
  name        = "default-alb-sg"
  description = "Security group for the Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creamos el ALB y le asignamos el security group creado anteriormente
resource "aws_lb" "application_load_balancer" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-12345678", "subnet-87654321"]

  enable_deletion_protection = true
}

# Creamos el security group para la instancia RDS a crear
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for the RDS instance"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creamos una instancia de RDS (PostgreSQL) y le asignamos el security group creado anteriormente
resource "aws_db_instance" "postgresql_rds" {
  allocated_storage    = 100
  engine               = "postgres"
  instance_class       = "db.t3.small"
  name                 = "rds-instance"
  username             = "rdsadmin"
  password             = "${var.rds_password}"
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_group_name      = "rds-subnet-group"
}

# Crear la hosted zone para Route53 (por definir)
resource "aws_route53_zone" "hosted_zone" {
  name = "example.com."
}

# Crear registro tipo A en Route53 (por definir)
resource "aws_route53_record" "alias_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "example.com."
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}