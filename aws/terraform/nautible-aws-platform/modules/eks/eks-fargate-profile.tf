data "aws_caller_identity" "self" {}

locals {
  test = pathexpand("~/${path.module}/main.tf")
  command_map = substr(local.test,0,1) == "/"? {
        command = var.wait_for_cluster_linux_cmd, 
        intrepreter = var.wait_for_cluster_linux_interpreter
      }:{
        command = var.wait_for_cluster_win_cmd, 
        intrepreter = var.wait_for_cluster_win_interpreter
      }
}
resource "null_resource" "wait_for_cluster" {

  depends_on = [module.eks]

  provisioner "local-exec" {
    command     = local.command_map.command
    interpreter = local.command_map.intrepreter
    environment = {
      ENDPOINT = module.eks.cluster_endpoint
    }
  }
}

# reason why create coredns fargate profile is following.
# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/fargate-getting-started.html
#resource "aws_eks_fargate_profile" "coredns-eks-fargate-profile" {
#  cluster_name           = module.eks.cluster_id
#  fargate_profile_name   = "coredns"
#  pod_execution_role_arn = var.create-iam-resources ? aws_iam_role.fargate-iam-role[0].arn : "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/FargatePodExecutionRole"
#  subnet_ids             = var.private-subnet-ids
#
#  depends_on = [null_resource.wait_for_cluster]
#
#  selector {
#    namespace = "kube-system"
#    labels = {
#      k8s-app = "kube-dns"
#    }
#  }
#
#  provisioner "local-exec" {
#    command = replace(replace(var.update-kubeconfig-and-coredns-deployment-command,"$REGION",var.region),"$CLUSTERNAME","${var.pjname}-cluster")
#  }
#  timeouts {
#    create = "30m"
#    delete = "45m"
#  }
#}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  cluster_name           = module.eks.cluster_id
  fargate_profile_name   = "${var.pjname}-fargate-profile"
  pod_execution_role_arn = var.create_iam_resources ? aws_iam_role.fargate_iam_role[0].arn : "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/FargatePodExecutionRole"
  subnet_ids             = var.private_subnet_ids

  depends_on = [null_resource.wait_for_cluster]

  #  depends_on = [module.eks, aws_eks_fargate_profile.coredns-eks-fargate-profile]

  #  selector {
  #    namespace = "default"
  #  }
  #  selector {
  #    namespace = "kube-system"
  #  }
  selector {
    namespace = var.pjname
  }
}
