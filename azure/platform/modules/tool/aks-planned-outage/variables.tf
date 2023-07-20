# Project name
variable "pjname" {
  default = "nautibledev"
}

# location 
variable "location" {
  default = "japaneast"
}

# aks start stop schedule weekdays
variable "aks_start_stop_schedule_weekdays" {
  default = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

# aks start schedule time
variable "aks_start_schedule_time" {
  default = "2023-07-21T09:00:00+09:00"
}

# aks stop schedule time
variable "aks_stop_schedule_time" {
  default = "2023-07-20T21:00:00+09:00"
}
