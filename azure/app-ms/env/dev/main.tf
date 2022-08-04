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
  vnet_id                                = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_id
  vnet_name                              = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_name
  vnet_rg_name                           = data.terraform_remote_state.nautible_azure_platform.outputs.vnet_rg_name
  aks_aci_subnet_cidr                    = data.terraform_remote_state.nautible_azure_platform.outputs.aks_aci_subnet_cidr
  nautible_service_principal_object_id   = data.terraform_remote_state.nautible_azure_platform.outputs.nautible_service_principal_object_id
  keyvault_private_dns_zone_id           = data.terraform_remote_state.nautible_azure_platform.outputs.keyvault_private_dns_zone_id
  cosmosdb_private_dns_zone_id           = data.terraform_remote_state.nautible_azure_platform.outputs.cosmosdb_private_dns_zone_id
  redis_private_dns_zone_id              = data.terraform_remote_state.nautible_azure_platform.outputs.redis_private_dns_zone_id
  product_db_subnet_cidr                 = var.product_db_subnet_cidr
  product_db_sku                         = var.product_db_sku
  product_db_administrator_login         = var.product_db_administrator_login
  product_db_administrator_password      = var.product_db_administrator_password
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
