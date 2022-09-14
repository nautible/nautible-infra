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
  source   = "../../"
  pjname   = var.pjname
  location = var.location
  vnet = {
    id      = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_id
    name    = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_name
    rg_name = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_rg_name
  }
  aks = {
    subnet_ids = data.terraform_remote_state.nautible_azure_platform.outputs.aks_subnet_ids
  }
  dns = {
    keyvault_private_dns_zone_id = data.terraform_remote_state.nautible_azure_platform.outputs.keyvault_private_dns_zone_id
  }
  # https://www.terraform.io/language/functions/merge#examples
  auth = merge(var.auth, { postgres = merge(var.auth.postgres,
  { administrator_login = var.auth_postgres_administrator_login, administrator_password = var.auth_postgres_administrator_password }) })

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
