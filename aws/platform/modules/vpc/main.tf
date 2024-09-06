module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"
  name    = "${var.pjname}-vpc"
  cidr    = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway    = var.nat_instance_type == null ? true : false
  single_nat_gateway    = var.nat_instance_type == null ? true : false
  enable_vpn_gateway    = false
  enable_dns_hostnames  = true
  private_subnet_suffix = "private-subnet"
  public_subnet_suffix  = "public-subnet"

  public_subnet_tags = merge(
    { for v in var.eks_cluster_names : "kubernetes.io/cluster/${v}" => "shared" },
    {
      "kubernetes.io/role/elb" = "1"
      "Name"                   = "${var.pjname}-public-subnet"
    }
  )

  private_subnet_tags = merge(
    { for v in var.eks_cluster_names : "kubernetes.io/cluster/${v}" => "shared" },
    { for v in var.eks_cluster_names : "karpenter.sh/discovery" => "${v}" },
    {
      "kubernetes.io/role/internal-elb" = "1"
      "Name"                            = "${var.pjname}-private-subnet"
    }
  )

  igw_tags = {
    "Name" = "${var.pjname}-igw"
  }

  public_route_table_tags = {
    "Name" = "${var.pjname}-public-rt"
  }

  private_route_table_tags = {
    "Name" = "${var.pjname}-private-rt"
  }

  tags = {
    Name = "${var.pjname}-vpc"
  }
}
