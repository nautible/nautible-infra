
module "nat_instance_security_group" {
  count   = var.nat_instance_type == null ? 0 : 1
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name   = "${var.pjname}-nat-instance-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "${var.pjname}-nat-instance-sg"
  }
}
