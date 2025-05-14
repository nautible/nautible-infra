module "albc_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name                             = "${var.cluster_name}-albc-sg"
  use_name_prefix                  = false
  description                      = "Security group for AWS Load Balancer Controller"
  vpc_id                           = var.vpc_id
  ingress_prefix_list_ids          = [var.albc_security_group_cloudfront_prefix_list_id] #cloudfront prefixlist
  computed_ingress_rules           = ["http-80-tcp"]
  number_of_computed_ingress_rules = 1
  egress_cidr_blocks               = ["0.0.0.0/0"]
  egress_rules                     = ["all-all"]

  tags = {
    Name = "${var.cluster_name}-albc-sg"
  }
}
