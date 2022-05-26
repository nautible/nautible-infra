provider "azurerm" {
  features {} // required but empty ok
}

terraform {
  # fix folloing value
  backend "azurerm" {
    resource_group_name  = "nautibledevterraform"
    storage_account_name = "nautibledevterraformsa"
    container_name       = "nautibledevterraformcontainer"
    key                  = "nautibledevapp.tfstate"
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

module "nautible_azure_app" {
  source                                 = "../../"
  pjname                                 = var.pjname
  location                               = var.location
  subnet_ids                             = data.terraform_remote_state.nautible_azure_platform.outputs.subnet_ids
  order_redis_capacity                   = var.order_redis_capacity
  order_redis_family                     = var.order_redis_family
  order_redis_sku_name                   = var.order_redis_sku_name
  servicebus_sku                         = var.servicebus_sku
  servicebus_max_delivery_count          = var.servicebus_max_delivery_count
  servicebus_max_size_in_megabytes       = var.servicebus_max_size_in_megabytes
  cosmosdb_public_network_access_enabled = var.cosmosdb_public_network_access_enabled
  cosmosdb_enable_free_tier              = var.cosmosdb_enable_free_tier
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
