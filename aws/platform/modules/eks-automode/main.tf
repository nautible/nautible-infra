data "aws_caller_identity" "self" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.36.0"
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name

  subnet_ids                               = var.private_subnet_ids
  vpc_id                                   = var.vpc_id
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  cluster_security_group_name              = "${var.cluster_name}-eks-cp-sg"
  cluster_security_group_use_name_prefix   = false
  node_security_group_name                 = "${var.cluster_name}-eks-node-common-sg"
  node_security_group_use_name_prefix      = false
  iam_role_name                            = "${var.cluster_name}-AmazonEKSClusterRole"
  iam_role_use_name_prefix                 = false
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = var.cluster_node_pools
  }

  cluster_security_group_additional_rules = {
    ingress_node_all = {
      description                = "Node to cluster all ports/protocols ingress"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_vpc_all = {
      description = "VPC resource to node all ports/protocols ingress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
    egress_vpc_all = {
      description = "Node to VPC resource all ports/protocols egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = [var.vpc_cidr]
    }

  }
  tags = {
    Name = "kubernetes.io/cluster/${var.cluster_name}-eks-cluster"
  }

}
