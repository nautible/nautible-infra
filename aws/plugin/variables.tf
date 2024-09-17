variable "project" {}
variable "environment" {}
variable "region" {}
variable "vpc" {}
variable "eks" {}
variable "auth" {}
variable "kong_apigateway" {}
variable "observation" {}

locals {
  pjname = "${var.project}-${var.environment}"
}
