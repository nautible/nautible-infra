variable "pjname" {}
variable "region" {}
variable "istio_ig_lb_name" {
  default = ""
}
variable "service_api_path_pattern" {}
variable "vpc_cidr" {}
variable "private_subnet_cidrs" {}
variable "public_subnet_cidrs" {}
variable "nat_instance_type" {}
variable "create_iam_resources" {}
variable "eks_cluster_version" {}
variable "eks_ng_desired_capacity" {}
variable "eks_ng_max_capacity" {}
variable "eks_ng_min_capacity" {}
variable "eks_ng_instance_type" {}
variable "eks_default_ami_type" {}
variable "eks_default_disk_size" {}
