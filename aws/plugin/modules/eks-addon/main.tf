resource "aws_eks_addon" "addon" {
  cluster_name                = var.cluster_name
  addon_name                  = var.name
  addon_version               = var.addon_version
  configuration_values        = var.configuration_values
  resolve_conflicts_on_create = var.resolve_conflicts_on_create
  resolve_conflicts_on_update = var.resolve_conflicts_on_update
  dynamic "pod_identity_association" {
    for_each = var.enable_pod_identity ? [1] : []
    content {
      role_arn        = aws_iam_role.pod_access_role[0].arn
      service_account = var.pod_identity_service_account
    }
  }
}