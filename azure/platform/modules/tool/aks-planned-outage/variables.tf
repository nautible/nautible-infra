# Project name
variable "pjname" {
  default = "nautibledev"
}

# location 
variable "location" {
  default = "japaneast"
}
# ask resource group name
variable "aks_rg_name" {
  default = "nautibledevaks"
}

# ask resource name
variable "aks_resource_name" {
  default = "nautibledevaks"
}

# aks start stop schedule weekdays
variable "aks_start_stop_schedule_weekdays" {
  default = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

# aks start schedule time
variable "aks_start_schedule_time" {
  default = "2021-06-17T09:00:00+09:00"
}

# aks stop schedule time
variable "aks_stop_schedule_time" {
  default = "2021-06-16T21:00:00+09:00"
}
