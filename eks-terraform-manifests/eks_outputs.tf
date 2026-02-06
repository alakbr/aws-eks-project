output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS API server endpoint"
}

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_version" {
  description = "EKS Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}


# ------------------------------------------------------------------------------
# Output the EKS Cluster Certificate Authority data
# Needed when setting up kubeconfig or accessing EKS via API
# ------------------------------------------------------------------------------
output "eks_cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Base64 encoded CA certificate for kubectl config"
}

# ------------------------------------------------------------------------------
# Output command to configure kubectl for this EKS cluster
# Helpful for students to run directly after apply
# ------------------------------------------------------------------------------
output "to_configure_kubectl" {
  description = "Command to update local kubeconfig to connect to the EKS cluster"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${local.eks_cluster_name}"
}

output "eks_sg" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "Security Group ID used by EKS control plane"

}

