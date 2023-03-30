module "eks" {
  source                                 = "terraform-aws-modules/eks/aws"
  version                                = "18.20.1"
  cluster_version                        = var.cluster_version
  cluster_name                           = var.cluster_name
  subnet_ids                             = var.private_subnet_ids
  vpc_id                                 = var.vpc_id
  cluster_endpoint_private_access        = var.cluster_endpoint_private_access
  cluster_endpoint_public_access         = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs   = var.cluster_endpoint_public_access_cidrs
  cluster_security_group_name            = "${var.cluster_name}-eks-cp-sg"
  cluster_security_group_use_name_prefix = false
  node_security_group_name               = "${var.cluster_name}-eks-node-common-sg"
  node_security_group_use_name_prefix    = false
  iam_role_name                          = "${var.cluster_name}-AmazonEKSClusterRole"
  iam_role_use_name_prefix               = false

  cluster_addons = {
    coredns = {
      name              = "coredns"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.cluster_addons_coredns_version
    }
    kube-proxy = {
      name              = "kube-proxy"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.cluster_addons_kube_proxy_version
    }
    vpc-cni = {
      name              = "vpc-cni"
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.cluster_addons_vpc_cni_version
    }
    aws-ebs-csi-driver = {
      name                     = "aws-ebs-csi-driver"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/${var.cluster_name}-AmazonEKS_EBS_CSI_DriverRole"
      addon_version            = var.cluster_addons_ebs_csi_driver_version
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                               = var.ng_ami_type
    disk_size                              = var.ng_disk_size
    update_launch_template_default_version = true
    iam_role_name                          = "${var.cluster_name}-AmazonEKSNodeRole"
    iam_role_use_name_prefix               = false
    security_group_use_name_prefix         = false
    network_interfaces = [
      {
        delete_on_termination = true
      }
    ]
    pre_bootstrap_user_data = <<-EOT
      #!/bin/bash
      set -ex
      cat <<-EOF > /etc/profile.d/bootstrap.sh
      export USE_MAX_PODS=false
      export KUBELET_EXTRA_ARGS="--max-pods=110"
      EOF
      # Source extra environment variables in bootstrap script
      sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
    EOT
  }

  eks_managed_node_groups = {
    "eks-default-node" = {
      security_group_name = "${var.cluster_name}-eks-default-node-sg"
      desired_size        = var.ng_desired_size
      max_size            = var.ng_max_size
      min_size            = var.ng_min_size
      instance_types      = [var.ng_instance_type]
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
    Name = "kubernetes.io/cluster/${var.cluster_name}-eks-cluster"
  }

}
