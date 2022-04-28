# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
data "aws_security_group" "eks_node_common_sg" {
  vpc_id = var.vpc_id
  name   = "${var.platform_pjname}-eks-node-common-sg"
}

resource "aws_ecrpublic_repository" "ecr_order" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-order"
}

data "aws_ssm_parameter" "order_elasticache_password" {
  name = "nautible-app-ms-order-elasticache-password"
}

resource "aws_security_group" "order_elasticache_sg" {
  name        = "${var.pjname}-order-statestore-sg"
  description = "security group for statestore"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = var.order_elasticache_port
    to_port         = var.order_elasticache_port
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "order_elasticache_subnet_group" {
  name       = "order-elasticache-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_replication_group" "order_elasticache_replication_group" {
  replication_group_id       = "order-statestore"
  description                = "order statestore"
  node_type                  = var.order_elasticache_node_type
  engine_version             = var.order_elasticache_engine_version
  parameter_group_name       = var.order_elasticache_parameter_group_name
  port                       = var.order_elasticache_port
  subnet_group_name          = aws_elasticache_subnet_group.order_elasticache_subnet_group.name
  security_group_ids         = [aws_security_group.order_elasticache_sg.id]
  transit_encryption_enabled = true
  auth_token                 = data.aws_ssm_parameter.order_elasticache_password.value
}

resource "aws_elasticache_cluster" "order_elasticache" {
  cluster_id           = "order-statestore"
  replication_group_id = aws_elasticache_replication_group.order_elasticache_replication_group.id
}

resource "aws_route53_record" "order_statestore_r53record" {
  zone_id = var.private_zone_id
  name    = "order-statestore.${var.private_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_replication_group.order_elasticache_replication_group.primary_endpoint_address]
}

resource "aws_dynamodb_table" "order" {
  name           = "Order"
  hash_key       = "OrderNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "OrderNo"
    type = "S"
  }

  attribute {
    name = "CustomerId"
    type = "N"
  }

  global_secondary_index {
    name            = "GSI-CustomerId"
    hash_key        = "CustomerId"
    range_key       = "OrderNo"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }
}

resource "aws_sqs_queue" "order_sqs_dapr_pubsub" {
  name = "nautible-app-ms-order"
  tags = {
    "dapr-queue-name" = "nautible-app-ms-order"
  }
}

resource "aws_sns_topic" "order_sns_topic_create_order_reply" {
  name = "create-order-reply"

  tags = {
    "dapr-topic-name" = "create-order-reply"
  }
}

resource "aws_sns_topic_subscription" "order_topic_subscription_create_order_reply" {
  topic_arn = aws_sns_topic.order_sns_topic_create_order_reply.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_sqs_dapr_pubsub.arn
}

