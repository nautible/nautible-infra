provider "aws" {
  region = var.region
}

module "common" {
  source          = "./modules/common"
  pjname          = var.pjname
  platform_pjname = var.platform_pjname
}

module "product" {
  source            = "./modules/product"
  pjname            = var.pjname
  platform_pjname   = var.platform_pjname
  vpc_id            = var.vpc_id
  private_subnets   = var.private_subnets
  private_zone_id   = var.private_zone_id
  private_zone_name = var.private_zone_name
}

module "customer" {
  source = "./modules/customer"
  pjname = var.pjname
}

module "stock" {
  source = "./modules/stock"
  pjname = var.pjname
}

module "order" {
  source                                 = "./modules/order"
  pjname                                 = var.pjname
  platform_pjname                        = var.platform_pjname
  vpc_id                                 = var.vpc_id
  private_subnets                        = var.private_subnets
  private_zone_id                        = var.private_zone_id
  private_zone_name                      = var.private_zone_name
  eks_node_security_group_id             = var.eks_node_security_group_id
  order_elasticache_node_type            = var.order_elasticache_node_type
  order_elasticache_parameter_group_name = var.order_elasticache_parameter_group_name
  order_elasticache_engine_version       = var.order_elasticache_engine_version
  order_elasticache_port                 = var.order_elasticache_port
}

module "payment" {
  source = "./modules/payment"
  pjname = var.pjname
}
