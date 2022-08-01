provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevpluginterraformcontainer"
    key                  = "nautibledevplugin.tfstate"
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

module "nautible_plugin" {
  source         = "../../"
  pjname         = var.pjname
  location       = var.location
  auth_variables = var.auth_variables

  vnet_rg_name                         = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_rg_name
  vnet_name                            = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_name
  vnet_id                              = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_id
  keyvault_rg                          = data.terraform_remote_state.nautible_azure_platform.outputs.keyvault_rg
  nautible_service_principal_object_id = data.terraform_remote_state.nautible_azure_platform.outputs.nautible_service_principal_object_id
}

data "terraform_remote_state" "nautible_azure_platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevplatform.tfstate"
  }
}
