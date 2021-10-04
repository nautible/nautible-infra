# Project name
variable "pjname" {
  default = "nautible-app-dev"
}
# AWS region
variable "region" {
  default = "ap-northeast-1"
}
# nautible aws platform state bucket
variable "nautible_aws_platform_state_bucket" {
  default = "nautible-aws-platform-dev-tf-ap-northeast-1"
}
# nautible aws platform state region
variable "nautible_aws_platform_state_region" {
  default = "ap-northeast-1"
}
# nautible aws platform state key
variable "nautible_aws_platform_state_key" {
  default = "nautible-aws-platform-dev.tfstate"
}
variable "order_elasticache_node_type" {
  default = "cache.t2.small"
}
variable "order_elasticache_parameter_group_name" {
  default = "default.redis5.0"
}
variable "order_elasticache_engine_version" {
  default = "5.0.6"
}
variable "order_elasticache_port" {
  default = "6379"
}
