module "eks" {
  source                                 = "terraform-aws-modules/eks/aws"
  version                                = "18.20.1"
  cluster_version                        = var.eks_cluster_version
  cluster_name                           = "${var.pjname}-cluster"
  subnet_ids                             = var.private_subnet_ids
  vpc_id                                 = var.vpc_id
  cluster_endpoint_private_access        = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access         = var.eks_cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs   = var.eks_cluster_endpoint_public_access_cidrs
  cluster_security_group_name            = "${var.pjname}-eks-cp-sg"
  cluster_security_group_use_name_prefix = false
  node_security_group_name               = "${var.pjname}-eks-node-common-sg"
  node_security_group_use_name_prefix    = false
  iam_role_name                          = "${var.pjname}-AmazonEKSClusterRole"
  iam_role_use_name_prefix               = false

  cluster_addons = {
    coredns = {
      name              = "coredns"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_cluster_addons_coredns_version
    }
    kube-proxy = {
      name              = "kube-proxy"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_cluster_addons_kube_proxy_version
    }
    vpc-cni = {
      name              = "vpc-cni"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_cluster_addons_vpc_cni_version
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                               = var.eks_default_ami_type
    disk_size                              = var.eks_default_disk_size
    update_launch_template_default_version = true
    iam_role_name                          = "${var.pjname}-AmazonEKSNodeRole"
    iam_role_use_name_prefix               = false
    security_group_use_name_prefix         = false
    network_interfaces = [
      {
        delete_on_termination = true
      }
    ]
  }

  eks_managed_node_groups = {
    "${var.pjname}-eks-default-node" = {
      security_group_name = "${var.pjname}-eks-default-node-sg"
      desired_size        = var.eks_ng_desired_size
      max_size            = var.eks_ng_max_size
      min_size            = var.eks_ng_min_size
      instance_types      = [var.eks_ng_instance_type]
    }
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

    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols ingress"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }

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
    Name = "kubernetes.io/cluster/${var.pjname}-eks-cluster"
  }

}
