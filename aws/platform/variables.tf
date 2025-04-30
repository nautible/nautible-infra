variable "project" {}
variable "environment" {}
variable "region" {}
variable "create_iam_resources" {}
variable "vpc" {}
variable "eks" {}
variable "eks_automode" {}
variable "cloudfront" {}
variable "oidc" {}
variable "github_organization" {}
variable "eks_mode" {}
locals {
  pjname = "${var.project}-${var.environment}"
}
