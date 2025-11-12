variable "project" {}
variable "environment" {}
variable "region" {}
variable "cluster_name" {}
variable "vpc" {}
variable "eks" {}
variable "eks_addon" {}
variable "auth" {}
variable "external_secrets" {}
variable "kong_apigateway" {}
variable "grafana" {}
variable "openobserve" {}

locals {
  pjname = "${var.project}-${var.environment}"
}
