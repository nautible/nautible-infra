module "eks" {
  for_each = { for i in var.eks : i.cluster.name => i }

  source                                        = "./modules/eks"
  pjname                                        = var.pjname
  region                                        = var.region
  vpc_id                                        = var.vpc_id
  vpc_cidr                                      = var.vpc_cidr
  public_subnet_ids                             = var.public_subnets
  private_subnet_ids                            = var.private_subnets
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
  ng_disk_size                                  = each.value.node_group.disk_size
  albc_security_group_cloudfront_prefix_list_id = each.value.albc_security_group_cloudfront_prefix_list_id
}