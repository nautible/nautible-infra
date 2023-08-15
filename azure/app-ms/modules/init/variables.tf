# resource group name
variable "terraform_resource_group_name" {
  default = "nautibledev"
}

# storage account name
variable "terraform_storage_account_name" {
  default = "nautibledevterraformsa"
}

# storage container name
variable "terraform_tfstate_storage_container_name" {
  default = "nautibledevappmsterraformcontainer"
}

# location 
variable "location" {
  default = "japaneast"
}
