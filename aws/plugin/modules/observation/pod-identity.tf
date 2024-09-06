resource "aws_eks_pod_identity_association" "observability_identity" {
  for_each        = toset(var.cluster_names)
  cluster_name    = each.value
  namespace       = "monitoring"
  service_account = "monitoring-sa"
  role_arn        = aws_iam_role.observability_role.arn
}
