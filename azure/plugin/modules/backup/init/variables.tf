# resource group name
variable "terraform_resource_group_name" {
  default = "nautibledevbackup"
}

# storage account name
variable "terraform_storage_account_name" {
  default = "nautibledevbkterraformsa"
}

# storage container name
variable "terraform_tfstate_storage_container_name" {
  default = "nautibledevpluginbackupterraformcontainer"
}

# location 
variable "location" {
  default = "japaneast"
}
