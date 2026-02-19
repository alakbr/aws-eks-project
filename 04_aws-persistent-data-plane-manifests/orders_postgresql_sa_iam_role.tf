resource "aws_iam_role" "orders_postgresql_getsecrets" {
  name = "orders_postgresql_getsecrets_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:orders"
        }
      }
    }]
  })
}
# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "orders_postgresql_db_secret_attach" {
  policy_arn = aws_iam_policy.secrets_csi_policy.arn
  role       = aws_iam_role.orders_postgresql_getsecrets.name
}

# Outputs
output "orders_postgresql_sa_getsecrets_role_arn" {
  description = "IAM Role ARN for Orders PostgreSQL Get Secrets from AWS Secrets Manager"
  value       = aws_iam_role.orders_postgresql_getsecrets.arn
}

resource "kubernetes_service_account" "orders_service_account" {
  metadata {
    name      = "orders"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.orders_postgresql_getsecrets.arn
    }
  }
}