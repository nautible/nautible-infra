variable "project" {}
variable "environment" {}
variable "platform_pjname" {}
variable "region" {}
variable "vpc" {}
variable "eks" {}
variable "order" {}
variable "product" {}

locals {
  pjname = "${var.project}-${var.environment}"
}
