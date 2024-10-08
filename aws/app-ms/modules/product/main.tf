# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_product" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-product"
}

resource "aws_security_group" "product_db_sg" {
  name        = "${var.pjname}-product-db-sg"
  description = "security group on product db"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "product_db_inbound_jdbc" {
  for_each                 = toset(var.eks_node_security_group_ids)
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.product_db_sg.id
}

resource "aws_security_group_rule" "product_db_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.product_db_sg.id
}

resource "aws_db_subnet_group" "product_db_dbsubnet" {
  name        = "${var.pjname}-product-db-dbsubnet"
  description = "db subnet group on vpc"
  subnet_ids  = [var.private_subnets[0], var.private_subnets[1]]
}

resource "aws_db_parameter_group" "product_db_dbpg" {
  name        = "product-db-dbpg"
  family      = var.parameter_family
  description = "db parameter group for product-db"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

data "aws_ssm_parameter" "product_db_user" {
  name = "nautible-app-ms-product-db-user"
}

data "aws_ssm_parameter" "product_db_password" {
  name = "nautible-app-ms-product-db-password"
}

resource "aws_db_instance" "product_db" {
  identifier                = "product-db"
  allocated_storage         = var.allocated_storage
  storage_type              = var.storage_type
  engine                    = "mysql"
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  db_name                   = "productdb"
  username                  = data.aws_ssm_parameter.product_db_user.value
  password                  = data.aws_ssm_parameter.product_db_password.value
  parameter_group_name      = aws_db_parameter_group.product_db_dbpg.name
  option_group_name         = var.option_group_name
  backup_retention_period   = 1
  skip_final_snapshot       = false
  final_snapshot_identifier = "product-db-final-snapshot"
  vpc_security_group_ids    = [aws_security_group.product_db_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.product_db_dbsubnet.name
}

resource "aws_route53_record" "product_db_r53record" {
  zone_id = var.private_zone_id
  name    = "product-db.${var.private_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.product_db.address]
}
