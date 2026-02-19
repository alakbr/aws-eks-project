# IAM Policy for DynamoDB Access (Cart microservice) - Full Access
resource "aws_iam_policy" "cart_dynamodb_policy" {
  name        = "${var.cluster_name}-cart-dynamodb-policy"
  description = "Allow Cart microservice full access to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource"
        ]
        Resource = "*" # Full access to all DynamoDB resources in all regions
      }
    ]
  })
}

resource "aws_iam_role" "cart_role" {
  name = "eks-cart-role"
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
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:carts"
        }
      }
    }]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "cart_dynamodb_policy_attach" {
  policy_arn = aws_iam_policy.cart_dynamodb_policy.arn
  role       = aws_iam_role.cart_role.name
}


# Outputs
output "cart_dynamodb_policy_arn" {
  description = "IAM Policy ARN for Cart microservice DynamoDB access"
  value       = aws_iam_policy.cart_dynamodb_policy.arn
}

output "cart_dynamodb_role_arn" {
  description = "IAM Role ARN for Cart microservice Pod Identity"
  value       = aws_iam_role.cart_role.arn
}

resource "kubernetes_service_account" "cart_service_account" {
  metadata {
    name      = "carts"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cart_role.arn
    }
  }
}