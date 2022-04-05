# Project name
variable "pjname" {
  default = "nautible-dev"
}
# AWS region
variable "region" {
  default = "ap-northeast-1"
}
# istio ingressgateway loadbalancer name
# Istioのロードバランサーを作成後にnameを指定してください。cloudfrontを作成し、s3とLBへルーティングします。 
# Istioのロードバランサー作成前は、ブランクを指定してください（cloudfrontの作成はスキップ）。
variable "istio_ig_lb_name" {
  # default = "afff962d46a7a4007afde76c7170fb3a"
  #default = "a7def79326db743b892680165d75f34c"
  default = ""
}
# service api path pattern for cloudfront routing to istio lb
variable "service_api_path_pattern" {
  default = "api/*"
}
# VPC cidr
variable "vpc_cidr" {
  default = "192.168.0.0/16"
}
# Public subnet cidr
variable "public_subnet_cidrs" {
  default = ["192.168.4.0/24", "192.168.5.0/24"]
}
# Private subnet cidr
variable "private_subnet_cidrs" {
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}
# デフォルト（NAT-instance typeを指定しない場合は）はNATGatewayを作成。
# NAT-instance typeを指定した場合はNATInstanceを作成。
variable "nat_instance_type" {
  default = null
  #default = "t2.small"
}
# create IAM resources(user,Role) or not
variable "create_iam_resources" {
  default = true
}

# eks cluster version
variable "eks_cluster_version" {
  default = "1.21"
}

# eks node-group desired capacity
variable "eks_ng_desired_capacity" {
  default = 3
}
# eks node-group max capacity
variable "eks_ng_max_capacity" {
  default = 5
}
# eks node-group min capacity
variable "eks_ng_min_capacity" {
  default = 3
}
# eks node-group instance type
variable "eks_ng_instance_type" {
  default = "t2.medium"
}

# eks node-group dafault ami type
variable "eks_default_ami_type" {
  default = "AL2_x86_64"
}
# eks node-group default dist size
variable "eks_default_disk_size" {
  default = 16
}
