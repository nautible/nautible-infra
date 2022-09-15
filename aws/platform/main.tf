module "vpc" {
  source               = "./modules/vpc"
  pjname               = var.pjname
  vpc_cidr             = var.vpc.vpc_cidr
  private_subnet_cidrs = var.vpc.private_subnet_cidrs
  public_subnet_cidrs  = var.vpc.public_subnet_cidrs
  nat_instance_type    = var.vpc.nat_instance_type
}

module "eks" {
  source                                        = "./modules/eks"
  pjname                                        = var.pjname
  region                                        = var.region
  vpc_id                                        = module.vpc.vpc_id
  vpc_cidr                                      = var.vpc.vpc_cidr
  public_subnet_ids                             = module.vpc.public_subnets
  private_subnet_ids                            = module.vpc.private_subnets
  create_iam_resources                          = var.create_iam_resources
  cluster_version                               = var.eks.cluster.version
  cluster_endpoint_private_access               = var.eks.cluster.endpoint_private_access
  cluster_endpoint_public_access                = var.eks.cluster.endpoint_public_access
  cluster_endpoint_public_access_cidrs          = var.eks.cluster.endpoint_public_access_cidrs
  cluster_addons_coredns_version                = var.eks.cluster.addons.coredns_version
  cluster_addons_vpc_cni_version                = var.eks.cluster.addons.vpc_cni_version
  cluster_addons_kube_proxy_version             = var.eks.cluster.addons.kube_proxy_version
  fargate_selectors                             = var.eks.fargate_selectors
  ng_desired_size                               = var.eks.node_group.desired_size
  ng_max_size                                   = var.eks.node_group.max_size
  ng_min_size                                   = var.eks.node_group.min_size
  ng_instance_type                              = var.eks.node_group.instance_type
  ng_ami_type                                   = var.eks.node_group.ami_type
  ng_disk_size                                  = var.eks.node_group.disk_size
  albc_security_group_cloudfront_prefix_list_id = var.eks.albc_security_group_cloudfront_prefix_list_id
}

module "route53" {
  source = "./modules/route53"
  pjname = var.pjname
  region = var.region
  vpc_id = module.vpc.vpc_id
}

module "cloudfront" {
  source                     = "./modules/cloudfront"
  pjname                     = var.pjname
  region                     = var.region
  cloudfront_origin_dns_name = var.cloudfront.origin_dns_name
  service_api_path_pattern   = var.cloudfront.service_api_path_pattern
}

module "oidc" {
  source = "./modules/oidc"
  pjname = var.pjname
  oidc   = var.oidc
}
