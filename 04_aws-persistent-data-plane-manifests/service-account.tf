resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

# resource "kubernetes_service_account" "ebs_csi" {
#   metadata {
#     name      = "ebs-csi-controller-sa"
#     namespace = "kube-system"

#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver.arn
#     }
#   }
# }

