module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.11.0"
  zones = {
    "${var.pjname}.com" = {
      comment = "${var.pjname}.com"
      tags = {
        env = "${var.pjname}.com"
      }
    }
    "vpc.${var.pjname}.com" = {
      comment = "vpc.${var.pjname}.com"
      vpc = {
        vpc_id     = var.vpc_id
        vpc_region = var.region
      }
      tags = {
        env = "vpc.${var.pjname}.com"
      }
    }
  }
}