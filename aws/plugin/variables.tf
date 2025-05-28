variable "project" {}
variable "environment" {}
variable "region" {}
variable "vpc" {}
variable "eks" {}
variable "auth" {}
variable "external_secrets" {}
variable "kong_apigateway" {}
variable "grafana" {}
variable "openobserve" {}

locals {
  pjname = "${var.project}-${var.environment}"
}
