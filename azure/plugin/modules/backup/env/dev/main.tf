provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevpluginterraformcontainer"
    key                  = "nautibledevbackup.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.24.0"
    }
  }
}

module "nautible_backup" {
  source                        = "../../"
  pjname                        = var.pjname
  location                      = var.location
  backup_resource_group_name    = var.backup_resource_group_name
  backup_storage_account_name   = var.backup_storage_account_name
  backup_storage_container_name = var.backup_storage_container_name
}
