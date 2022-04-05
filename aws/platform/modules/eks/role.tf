resource "random_id" "fargate_iam_role_random" {
  byte_length = 8
}

resource "aws_iam_role" "fargate_iam_role" {
  count              = var.create_iam_resources ? 1 : 0
  name               = "FargatePodExecutionRole-${random_id.fargate_iam_role_random.dec}"
  assume_role_policy = data.aws_iam_policy_document.fargate_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "fargate_pod_exec_role_policy_attachment" {
  count      = var.create_iam_resources ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_iam_role[0].name
}

#https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md
#https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/cluster-autoscaler.html
resource "aws_iam_role_policy" "worker_autoscaling_policy" {
  name = "${var.pjname}-eks-worker-autoscaling-policy"
  role = module.eks.worker_iam_role_name

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"      
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}