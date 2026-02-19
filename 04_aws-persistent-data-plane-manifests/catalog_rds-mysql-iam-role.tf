resource "aws_iam_role" "catalog_rds" {
  name = "catalog_rds_role"

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
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:catalog"
        }
      }
    }]
  })
}
# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "catalog_rds_attach" {
  policy_arn = aws_iam_policy.secrets_csi_policy.arn
  role       = aws_iam_role.catalog_rds.name
}

resource "kubernetes_service_account" "catalog_service_account" {
  metadata {
    name      = "catalog"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.catalog_rds.arn
    }
  }
}