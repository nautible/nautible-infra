provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevplatform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.6.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }

  }

}

module "nautible_azure_platform" {
  source              = "../../"
  pjname              = var.pjname
  location            = var.location
  vnet                = var.vnet
  aks                 = var.aks
  static_web          = var.static_web
  frontdoor           = var.frontdoor
  dns                 = var.dns
}
