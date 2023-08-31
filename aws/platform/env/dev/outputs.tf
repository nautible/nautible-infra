output "pjname" {
  value = var.pjname
}
output "vpc_cidr" {
  value = var.vpc.vpc_cidr
}
output "create_iam_resources" {
  value = var.create_iam_resources
}
output "region" {
  value = var.region
}
output "vpc" {
  value = module.nautible_aws_platform.vpc
}
output "route53" {
  value = module.nautible_aws_platform.route53
}