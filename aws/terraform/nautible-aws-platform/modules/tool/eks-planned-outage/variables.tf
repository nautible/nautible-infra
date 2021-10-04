# aws region 
variable "region" {
  default = "ap-northeast-1"
}
# fix auto scaling group name
variable "auto_scaling_group_name" {
  default = "fix me"
}
variable "max_size" {
  default = "5"
}
variable "min_size" {
  default = "3"
}
variable "desired_capacity" {
  default = "3"
}
variable "stop_schedule" {
  default = "cron(0 12 ? * MON-FRI *)"
}
variable "start_schedule" {
  default = "cron(0 22 ? * SUN-THU *)"
}
