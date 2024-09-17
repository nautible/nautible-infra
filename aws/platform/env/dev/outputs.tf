output "pjname" {
  value = "${var.project}-${var.environment}"
}
output "vpc" {
  value = module.nautible_aws_platform.vpc
}
output "eks" {
  value = module.nautible_aws_platform.eks
}
output "route53" {
  value = module.nautible_aws_platform.route53
}
