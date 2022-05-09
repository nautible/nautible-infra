# S3 bucket name for terraform tfstate
variable "terraform_bucket_name" {
  default = "nautible-dev-app-ms-tf-ap-northeast-1"
}
# dynamodb table name for terraform tfstate lock
# if you don't need to lock, set null.
variable "terraform_state_lock_table_name" {
  #default = null
  default = "nautible-dev-app-ms-tfstate-lock"
}
# aws region 
variable "region" {
  default = "ap-northeast-1"
}
