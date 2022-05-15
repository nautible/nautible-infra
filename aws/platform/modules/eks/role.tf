resource "random_id" "fargate_iam_role_random" {
  byte_length = 8
}

data "aws_iam_policy_document" "fargate_assume_role_policy" {
  statement {
    sid = "EKSFargateAssumePolicy"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate_iam_role" {
  count              = var.create_iam_resources ? 1 : 0
  name               = "${var.pjname}-AmazonEKSFargatePodExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.fargate_assume_role_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  ]
  tags = {
    Name = "${var.pjname}-AmazonEKSFargatePodExecutionRole"
  }
}

#https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks
module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "${var.pjname}-AmazonEKSClusterAutoscalerRole"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_id]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["autoscaler:cluster-autoscaler-aws-cluster-autoscaler"]
    }
  }

  tags = {
    Name = "${var.pjname}-AmazonEKSClusterAutoscalerRole"
  }

}

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.pjname}-AmazonEKSLoadBalancerControllerRole"
  attach_load_balancer_controller_policy = true
  policy_name_prefix = "${var.pjname}-"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name = "${var.pjname}-AmazonEKSLoadBalancerControllerRole"
  }
}
