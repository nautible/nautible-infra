resource "random_id" "fargate_iam_role_random" {
  byte_length = 8
}

data "aws_iam_policy_document" "fargate_assume_role_policy" {
  statement {
    sid = "EKSFargateAssumePolicy"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate_iam_role" {
  count              = var.create_iam_resources ? 1 : 0
  name               = "${var.cluster_name}-AmazonEKSFargatePodExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.fargate_assume_role_policy.json

  tags = {
    Name = "${var.cluster_name}-AmazonEKSFargatePodExecutionRole"
  }
}

resource "aws_iam_role_policy_attachment" "fargate_iam_role_attach" {
  count      = var.create_iam_resources ? 1 : 0
  role       = aws_iam_role.fargate_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}
