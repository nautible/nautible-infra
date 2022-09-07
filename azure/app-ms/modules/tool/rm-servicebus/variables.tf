# Project name
variable "pjname" {
  default = "nautibledev"
}

# location 
variable "location" {
  default = "japaneast"
}

# schedule weekdays
variable "schedule_weekdays" {
  default = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
}

# schedule time
variable "schedule_time" {
  default = "2022-08-08T21:00:00+09:00"
}