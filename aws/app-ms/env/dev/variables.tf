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
  default = "nautible-dev-platform-tf-ap-northeast-1"
}
# nautible aws platform state region
variable "nautible_aws_platform_state_region" {
  default = "ap-northeast-1"
}
# nautible aws platform state key
variable "nautible_aws_platform_state_key" {
  default = "nautible-dev-platform.tfstate"
}
variable "order_elasticache_node_type" {
  default = "cache.t2.micro"
}
variable "order_elasticache_parameter_group_name" {
  default = "default.redis6.x"
}
variable "order_elasticache_engine_version" {
  default = "6.x"
}
variable "order_elasticache_port" {
  default = "6379"
}
