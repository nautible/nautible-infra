module "common" {
  source                              = "./modules/common"
  pjname                              = local.pjname
  region                              = var.region
  platform_pjname                     = var.platform_pjname
  eks_oidc_provider_arns              = values(var.eks).*.oidc.provider_arn
  eks_cluster_name_node_role_name_map = zipmap(values(var.eks).*.cluster.name, values(var.eks).*.node.role_name)
}

module "product" {
  source                      = "./modules/product"
  pjname                      = local.pjname
  platform_pjname             = var.platform_pjname
  vpc_id                      = var.vpc.vpc_id
  private_subnets             = var.vpc.private_subnets
  private_zone_id             = var.vpc.private_zone_id
  private_zone_name           = var.vpc.private_zone_name
  eks_node_security_group_ids = values(var.eks).*.node.security_group_id
  engine_version              = var.product.mysql.engine_version
  instance_class              = var.product.mysql.instance_class
  option_group_name           = var.product.mysql.option_group_name
  storage_type                = var.product.mysql.storage_type
  allocated_storage           = var.product.mysql.allocated_storage
  parameter_family            = var.product.mysql.parameter_group.family
  parameters                  = var.product.mysql.parameter_group.parameters
}

module "customer" {
  source = "./modules/customer"
  pjname = local.pjname
}

module "stock" {
  source = "./modules/stock"
  pjname = local.pjname
}

module "stockbatch" {
  source = "./modules/stockbatch"
  pjname = local.pjname
}

module "order" {
  source                                 = "./modules/order"
  pjname                                 = local.pjname
  platform_pjname                        = var.platform_pjname
  vpc_id                                 = var.vpc.vpc_id
  private_subnets                        = var.vpc.private_subnets
  private_zone_id                        = var.vpc.private_zone_id
  private_zone_name                      = var.vpc.private_zone_name
  eks_node_security_group_ids            = values(var.eks).*.node.security_group_id
  order_elasticache_node_type            = var.order.elasticache.node_type
  order_elasticache_parameter_group_name = var.order.elasticache.parameter_group_name
  order_elasticache_engine_version       = var.order.elasticache.engine_version
  order_elasticache_port                 = var.order.elasticache.port
}

module "payment" {
  source = "./modules/payment"
  pjname = local.pjname
}

module "delivery" {
  source = "./modules/delivery"
  pjname = local.pjname
}
