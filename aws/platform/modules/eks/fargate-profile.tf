data "aws_caller_identity" "self" {}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  count                  = length(var.eks_fargate_selectors) > 0 ? 1 : 0
  cluster_name           = module.eks.cluster_id
  fargate_profile_name   = "${var.pjname}-fargate-profile"
  pod_execution_role_arn = var.create_iam_resources ? aws_iam_role.fargate_iam_role[0].arn : "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/FargatePodExecutionRole"
  subnet_ids             = var.private_subnet_ids

  dynamic "selector" {
    for_each = { for i in var.eks_fargate_selectors : i.namespace => i }
    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }

  tags = {
    Name = "${var.pjname}-fargate-profile"
  }

}
