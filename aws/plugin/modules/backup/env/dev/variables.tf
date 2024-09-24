# Project name
variable "project" {
  description = "プロジェクト名称 ex) nautible"
  # default = ""
}

variable "environment" {
  description = "環境名定義"
  default     = "dev"
}

# AWS region
variable "region" {
  default = "ap-northeast-1"
}

# platform tfstate
variable "platform_tfstate" {
  description = "platform tfstate設定"
  default     = "nautible-dev-platform.tfstate"
}

locals {
  backend_config = jsondecode(file(".terraform/terraform.tfstate"))
}
