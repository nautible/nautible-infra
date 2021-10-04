variable "pjname" {}
variable "region" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "create_iam_resources" {}
variable "eks_cluster_version" {}
variable "eks_ng_desired_capacity" {}
variable "eks_ng_max_capacity" {}
variable "eks_ng_min_capacity" {}
variable "eks_ng_instance_type" {}
variable "eks_default_ami_type" {}
variable "eks_default_disk_size" {}


# use fargate,so don't need following resources.
# create iam resources for autoscaling group of workers. see aws eks modules.
variable "manage_worker_iam_resources" {
  default = false
}
# use fargate,so don't need following resources.
# create security group resources for autoscaling group of workers. see aws eks modules.
variable "worker_create_security_group" {
  default = false
}
# can't set specific security group name, so don't use aws eks modules to create cluster security group.
# create security group resources for cluster
variable "cluster_create_security_group" {
  default = false
}
# it is depends on aws-iam-authenticator and it is old way to access.
# create kubeconfig file.
variable "manage_aws_auth" {
  default = false
}

variable "wait_for_cluster_linux_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "for i in `seq 1 60`; do wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; sleep 5; done; echo TIMEOUT && exit 1"
}
variable "wait_for_cluster_linux_interpreter" {
  description = "Custom local-exec command line interpreter for the command to determining if the eks cluster is healthy."
  type        = list(string)
  default     = ["/bin/sh", "-c"]
}
variable "wait_for_cluster_win_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "for /l %i in (1,1,60) do ( curl -k %ENDPOINT%/healthz && exit || powershell sleep 5 )"
}
variable "wait_for_cluster_win_interpreter" {
  description = "Custom local-exec command line interpreter for the command to determining if the eks cluster is healthy."
  type        = list(string)
  default     = ["cmd", "/c"]
}
#variable "update-kubeconfig-and-coredns-deployment-command" {
#  default     = "aws eks --region $REGION update-kubeconfig --name $CLUSTERNAME && kubectl patch deployment coredns -n kube-system --type=json -p='[{'op': 'remove', 'path': '/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type'}]'"
#}