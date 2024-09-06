module "karpenter" {
  count   = var.use_karpenter ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.17"

  cluster_name = module.eks.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "${module.eks.cluster_name}-KarpenterNodeRole"
  create_pod_identity_association = true
}

