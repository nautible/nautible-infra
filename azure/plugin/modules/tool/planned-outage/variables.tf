# Project name
variable "pjname" {
  default = "nautibledev"
}

# location 
variable "location" {
  default = "japaneast"
}
# ask resource group name
variable "auth_postgresql_rg_name" {
  default = "nautibledevkeycloak"
}

# ask resource name
variable "auth_postgresql_resource_name" {
  default = "keycloakdbserver"
}

# aks start stop schedule weekdays
variable "auth_postgresql_start_stop_schedule_weekdays" {
  default = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

# aks start schedule time
variable "auth_postgresql_start_schedule_time" {
  default = "2022-06-30T09:00:00+09:00"
}

# aks stop schedule time
variable "auth_postgresql_stop_schedule_time" {
  default = "2022-06-30T21:00:00+09:00"
}
