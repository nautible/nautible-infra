data "aws_ssm_parameter" "keycloak_db_user" {
  name = "nautible-plugin-keycloak-db-user"
}

data "aws_ssm_parameter" "keycloak_db_password" {
  name = "nautible-plugin-keycloak-db-password"
}

data "aws_caller_identity" "self" {}

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
  for_each                 = toset(var.eks_node_security_group_ids)
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = each.value
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
  allocated_storage      = var.postgres_allocated_storage
  storage_type           = var.postgres_storage_type
  engine                 = "postgres"
  engine_version         = var.postgres_engine_version
  instance_class         = var.postgres_instance_class
  db_name                = "keycloak"
  username               = data.aws_ssm_parameter.keycloak_db_user.value
  password               = data.aws_ssm_parameter.keycloak_db_password.value
  parameter_group_name   = var.postgres_parameter_group_name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.keycloak_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.keycloak_db_dbsubnet.name
}

resource "aws_iam_role" "auth_secret_access_role" {
  name = "${var.pjname}-auth-secret-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.eks_oidc_provider_arns
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "auth_secret_access_role_policy" {
  name = "${var.pjname}-auth-secret-access-role-policy"
  role = aws_iam_role.auth_secret_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.self.account_id}:secret:nautible-plugin-keycloak*"
        ]
      }
    ]
  })
}
