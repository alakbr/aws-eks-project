# Security Group for RDS PostgreSQL
# Allow access only from EKS Cluster security group
resource "aws_security_group" "rds_postgresql_sg" {
  name        = "${var.cluster_name}-rds-postgresql-sg"
  description = "Allow RDS PostgreSQL access from EKS cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  depends_on = [ aws_secretsmanager_secret.retailstore_db ]

  ingress {
    description     = "Allow RDS PostgreSQL from EKS Cluster"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.eks.outputs.eks_sg,
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
    Name = "${var.cluster_name}-rds-postgresql-sg"
  }
}

