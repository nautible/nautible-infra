data "aws_ssm_parameter" "keycloak_db_user" {
  name = "nautible-infra-keycloak-db-user"
}

data "aws_ssm_parameter" "keycloak_db_password" {
  name = "nautible-infra-keycloak-db-password"
}

resource "aws_db_subnet_group" "keycloak_db_dbsubnet" {
  name       = "${var.pjname}-keycloak-db-dbsubnet"
  subnet_ids = [var.private_subnets[0], var.private_subnets[1]]
}

resource "aws_security_group" "keycloak_db_sg" {
  name        = "${var.pjname}-keycloak-db-sg"
  description = "security group on product db"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "keycloak_db_inbound" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_security_group_id
  security_group_id        = aws_security_group.keycloak_db_sg.id
}

resource "aws_security_group_rule" "keycloak_db_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.keycloak_db_sg.id
}

resource "aws_db_instance" "keycloak_db" {
  identifier             = "keycloak"
  allocated_storage      = var.auth_variables.postgres.allocated_storage
  storage_type           = var.auth_variables.postgres.storage_type
  engine                 = "postgres"
  engine_version         = var.auth_variables.postgres.engine_version
  instance_class         = var.auth_variables.postgres.instance_class
  db_name                = "keycloak"
  username               = data.aws_ssm_parameter.keycloak_db_user.value
  password               = data.aws_ssm_parameter.keycloak_db_password.value
  parameter_group_name   = var.auth_variables.postgres.parameter_group_name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.keycloak_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.keycloak_db_dbsubnet.name
}
