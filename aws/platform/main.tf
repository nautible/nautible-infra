module "vpc" {
  source               = "./modules/vpc"
  pjname               = local.pjname
  vpc_cidr             = var.vpc.vpc_cidr
  private_subnet_cidrs = var.vpc.private_subnet_cidrs
  public_subnet_cidrs  = var.vpc.public_subnet_cidrs
  nat_instance_type    = var.vpc.nat_instance_type
  eks_cluster_names    = var.eks.*.cluster.name
}

module "eks" {
  for_each = { for i in var.eks : i.cluster.name => i }

  source                                        = "./modules/eks"
  pjname                                        = local.pjname
  region                                        = var.region
  vpc_id                                        = module.vpc.vpc_id
  vpc_cidr                                      = var.vpc.vpc_cidr
  public_subnet_ids                             = module.vpc.public_subnets
  private_subnet_ids                            = module.vpc.private_subnets
  create_iam_resources                          = var.create_iam_resources
  cluster_name                                  = each.value.cluster.name
  cluster_version                               = each.value.cluster.version
  cluster_endpoint_private_access               = each.value.cluster.endpoint_private_access
  cluster_endpoint_public_access                = each.value.cluster.endpoint_public_access
  cluster_endpoint_public_access_cidrs          = each.value.cluster.endpoint_public_access_cidrs
  cluster_addons_coredns_version                = each.value.cluster.addons.coredns_version
  cluster_addons_vpc_cni_version                = each.value.cluster.addons.vpc_cni_version
  cluster_addons_kube_proxy_version             = each.value.cluster.addons.kube_proxy_version
  cluster_addons_ebs_csi_driver_version         = each.value.cluster.addons.ebs_csi_driver_version
  fargate_selectors                             = each.value.fargate_selectors
  ng_desired_size                               = each.value.node_group.desired_size
  ng_max_size                                   = each.value.node_group.max_size
  ng_min_size                                   = each.value.node_group.min_size
  ng_instance_type                              = each.value.node_group.instance_type
  ng_ami_type                                   = each.value.node_group.ami_type
  ng_ami_id                                     = each.value.node_group.ami_id
  ng_disk_size                                  = each.value.node_group.disk_size
  ng_enable_bootstrap_user_data                 = each.value.node_group.enable_bootstrap_user_data
  ng_pre_bootstrap_user_data                    = each.value.node_group.pre_bootstrap_user_data
  ng_cloudinit_pre_nodeadm                      = each.value.node_group.cloudinit_pre_nodeadm
  albc_security_group_cloudfront_prefix_list_id = each.value.albc_security_group_cloudfront_prefix_list_id
  albc_role_arn                                 = module.eks-pod-identity.albc_role_arn
  csi_driver_role_arn                           = module.eks-pod-identity.csi_driver_role_arn
  autoscaler_role_arn                           = module.eks-pod-identity.autoscaler_role_arn
}

module "eks-pod-identity" {
  source = "./modules/eks-pod-identity"

  pjname = local.pjname
}

module "route53" {
  source = "./modules/route53"
  pjname = local.pjname
  region = var.region
  vpc_id = module.vpc.vpc_id
}

module "cloudfront" {
  source                     = "./modules/cloudfront"
  pjname                     = local.pjname
  region                     = var.region
  cloudfront_origin_dns_name = var.cloudfront.origin_dns_name
  service_api_path_pattern   = var.cloudfront.service_api_path_pattern
}

module "oidc" {
  source               = "./modules/oidc"
  pjname               = local.pjname
  oidc                 = var.oidc
  github_organization  = var.github_organization
  static_web_bucket_id = module.cloudfront.static_web_bucket_id
}
