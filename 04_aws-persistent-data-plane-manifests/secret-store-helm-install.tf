resource "helm_release" "secrets_store_csi" {
  name       = "secrets-store-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"

  set = [
    {
      name  = "serviceAccount.create"
      value = "true"
    },

    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.secrets_csi_role.arn
    },

    {
      name  = "serviceAccount.name"
      value = "secrets-store-csi-driver"
    },

    {
      name  = "syncSecret.enabled"
      value = "true"
    }

  ]

  # Wait until all pods are ready
  wait            = true
  timeout         = 600
  cleanup_on_fail = true
}


resource "helm_release" "aws_provider" {
  name       = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"

  # Disable re-installation of CSI driver (already installed separately)
  set = [
    {
      name  = "secrets-store-csi-driver.install"
      value = "false"
    }
  ]

  # Wait for all pods to become ready
  wait            = true
  timeout         = 600
  cleanup_on_fail = true

  depends_on = [
    helm_release.secrets_store_csi
  ]
}
