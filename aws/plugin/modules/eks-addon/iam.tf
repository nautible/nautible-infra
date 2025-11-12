resource "aws_iam_role" "pod_access_role" {
  count  = var.enable_pod_identity ? 1 : 0
  name               = "${var.cluster_name}-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.pod_access_role_document.json
}

resource "aws_iam_role_policy_attachment" "pod_access_policy_attachment" {
  for_each = var.enable_pod_identity && length(var.service_policy_arns) > 0 ? toset(var.service_policy_arns) : toset([])
  role       = aws_iam_role.pod_access_role[0].name
  policy_arn = each.key
}