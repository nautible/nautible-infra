variable "project" {}
variable "environment" {}
variable "region" {}
variable "create_iam_resources" {}
variable "vpc" {}
variable "eks" {}
variable "cloudfront" {}
variable "oidc" {}
variable "github_organization" {}

locals {
  pjname = "${var.project}-${var.environment}"
}
