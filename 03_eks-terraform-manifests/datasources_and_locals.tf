# --------------------------------------------------------------------
# Local values used throughout the EKS configuration
# Helps enforce naming consistency and reduce duplication
# --------------------------------------------------------------------
locals {
  # Business division or team name (from variable)
  owners = var.business_division # Example: "retail"

  # Environment name such as dev, staging, prod (from variable)
  environment = var.environment_name # Example: "dev"

  # Standardized naming prefix: "<division>-<env>"
  name = "${local.owners}-${local.environment}" # Example: "retail-dev"

  # Full EKS cluster name used for resource naming and tagging
  eks_cluster_name = "demo-eks" # Example: "retail-dev-eksdemo"

  cluster_endpoint = aws_eks_cluster.main.endpoint
  cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
}