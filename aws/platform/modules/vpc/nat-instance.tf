
module "nat_instance" {
  count   = var.nat_instance_type == null ? 0 : 1
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name                        = "${var.pjname}-nat-instance"
  ami                         = data.aws_ami.nat_ami_recent[0].id
  instance_type               = var.nat_instance_type
  monitoring                  = true
  source_dest_check           = false
  vpc_security_group_ids      = [module.nat_instance_security_group[0].security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name = "${var.pjname}-nat-instance"
  }
}


