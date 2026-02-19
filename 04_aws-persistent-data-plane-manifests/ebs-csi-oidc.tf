# resource "aws_iam_role" "ebs_csi_driver" {
#   name = "eks-ebs-csi-driver-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.eks.arn
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(
#               data.aws_eks_cluster.main.identity[0].oidc[0].issuer,
#               "https://",
#               ""
#             )}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
#   role       = aws_iam_role.ebs_csi_driver.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# ############################################
# # Install EBS CSI Addon
# ############################################

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
#   addon_name   = "aws-ebs-csi-driver"

#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     aws_iam_role_policy_attachment.ebs_csi_policy
#   ]

#   tags = {
#     Name        = "${var.cluster_name}-aws-ebs-csi-addon"
#     Environment = var.environment_name
#     Component   = "Amazon EBS CSI Driver"
#   }
# }

