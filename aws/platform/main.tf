module "vpc" {
  source               = "./modules/vpc"
  pjname               = var.pjname
  vpc_cidr             = var.vpc.vpc_cidr
  private_subnet_cidrs = var.vpc.private_subnet_cidrs
  public_subnet_cidrs  = var.vpc.public_subnet_cidrs
  nat_instance_type    = var.vpc.nat_instance_type
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
  source               = "./modules/oidc"
  pjname               = var.pjname
  oidc                 = var.oidc
  static_web_bucket_id = module.cloudfront.static_web_bucket_id
}
