data "aws_region" "current" {
}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "nat_ami_recent" {
  count       = var.nat_instance_type == null ? 0 : 1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
