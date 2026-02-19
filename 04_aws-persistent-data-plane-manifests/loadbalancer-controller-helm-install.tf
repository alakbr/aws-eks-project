# Install AWS Load Balancer Controller using HELM
resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    aws_iam_role.alb_controller
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  # version  = "1.13.0"         # Recommended in prod, if not specified always uses latest version

  wait            = true # Wait for resources to become Ready
  timeout         = 600
  cleanup_on_fail = true

  set = [
    # Create Service Account via Helm
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    # Service Account Name
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    # EKS Cluster Name
    {
      name  = "clusterName"
      value = "${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
    },
    # VPC Id
    {
      name  = "vpcId"
      value = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
    },
    # AWS Region
    {
      name  = "region"
      value = "${var.aws_region}"
    }
  ]
}


# Helm Release Outputs
output "helm_lbc_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.loadbalancer_controller.metadata
}



