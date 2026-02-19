# RDS MySQL Database Instance
resource "aws_db_instance" "catalog_rds" {
  identifier               = "mydb3"
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  db_name                  = "catalogdb"
  username                 = local.retailstore_secret_json.username
  password                 = local.retailstore_secret_json.password
  db_subnet_group_name     = aws_db_subnet_group.rds_private.name
  vpc_security_group_ids   = [aws_security_group.rds_mysql_sg.id]
  skip_final_snapshot      = true
  publicly_accessible      = false
  delete_automated_backups = true
  multi_az                 = false
  backup_retention_period  = 1

  tags = {
    Name = "${var.cluster_name}-catalog-rds-mysql"
  }
}


# Outputs
output "catalog_rds_endpoint" {
  description = "RDS endpoint for Catalog microservice"
  value       = aws_db_instance.catalog_rds.address
}

output "catalog_rds_sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_mysql_sg.id
}



# Security Group for RDS MySQL
resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.cluster_name}-rds-mysql-sg"
  description = "Allow MySQL access from EKS cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow MySQL from EKS cluster security group and node group security group"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      data.terraform_remote_state.eks.outputs.eks_sg,
      data.terraform_remote_state.eks.outputs.node_group_security_group
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-mysql-sg"
  }
}

# DB Subnet Group (using private subnets from VPC project)
resource "aws_db_subnet_group" "rds_private" {
  name       = "${var.cluster_name}-rds-private-subnets"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "${var.cluster_name}-rds-private-subnets"
  }
}

locals {
  retailstore_secret_json = jsondecode(aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)
}