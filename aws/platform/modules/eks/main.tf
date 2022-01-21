module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_version = var.eks_cluster_version
  cluster_name    = "${var.pjname}-cluster"
  subnets         = var.private_subnet_ids
  vpc_id          = var.vpc_id
  #manage_worker_iam_resources   = var.manage_worker_iam_resources
  #worker_create_security_group  = var.worker_create_security_group
  manage_aws_auth               = var.manage_aws_auth
  cluster_create_security_group = var.cluster_create_security_group
  # write_kubeconfig depends on aws-iam-authenticator and it is old way to access.
  write_kubeconfig          = false
  cluster_security_group_id = module.cluster_security_group.security_group_id

  node_groups_defaults = {
    ami_type  = var.eks_default_ami_type
    disk_size = var.eks_default_disk_size
  }

  node_groups = {
    default = {
      desired_capacity = var.eks_ng_desired_capacity
      max_capacity     = var.eks_ng_max_capacity
      min_capacity     = var.eks_ng_min_capacity
      instance_types    = [var.eks_ng_instance_type]
    }
  }

  tags = {
    Name = "kubernatis.io/cluster/${var.pjname}-eks-cluster"
  }
}

# do not use terraform-module/eks-fargate-profile/aws. because
# specific profile name can't set. coredns. 
# multi namespace can't set.
#module "eks_fargate" {
#  source  = "terraform-module/eks-fargate-profile/aws"
#
#  cluster_name         = "${var.pjname}-eks-cluster"
#  subnet_ids           = var.private-subnet-ids
#  namespaces           = "kube-system"
#}

