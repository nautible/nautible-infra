# Azure Front Door (Standard/Premium) Profile
resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = "${var.pjname}frontdoor"
  resource_group_name = var.rgname
  sku_name            = "Standard_AzureFrontDoor" # または "Premium_AzureFrontDoor"
  tags                = {}
}

# Endpoint for Static Web
resource "azurerm_cdn_frontdoor_endpoint" "staticweb" {
  name                     = "${var.pjname}staticweb"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

# Origin Group for Static Web
resource "azurerm_cdn_frontdoor_origin_group" "staticweb" {
  name                     = "${var.pjname}staticwebbp"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  
  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }
}

# Origin for Static Web
resource "azurerm_cdn_frontdoor_origin" "staticweb" {
  name                          = "${var.pjname}staticweb"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.staticweb.id
  
  enabled                        = true
  host_name                      = var.static_web_primary_web_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.static_web_primary_web_host
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

# Route for Static Web
resource "azurerm_cdn_frontdoor_route" "staticweb" {
  name                          = "${var.pjname}staticwebroute"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.staticweb.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.staticweb.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.staticweb.id]
  
  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}

# API用の設定（istio_ig_lb_ipが設定されている場合）
resource "azurerm_cdn_frontdoor_origin_group" "api" {
  count                    = var.istio_ig_lb_ip != null ? 1 : 0
  name                     = "${var.pjname}apibp"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  
  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/healthz"
    protocol            = "Http"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "api" {
  count                         = var.istio_ig_lb_ip != null ? 1 : 0
  name                          = "${var.pjname}api"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.api[0].id
  
  enabled                        = true
  host_name                      = var.istio_ig_lb_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.istio_ig_lb_ip
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_route" "api" {
  count                         = var.istio_ig_lb_ip != null ? 1 : 0
  name                          = "${var.pjname}apiroute"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.staticweb.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.api[0].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.api[0].id]
  
  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = [var.service_api_path_pattern]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
}

# Diagnostic Settings
resource "azurerm_storage_account" "frontdoor_log_sa" {
  name                     = "${var.pjname}frontdoorlog"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action = "Deny"
    ip_rules       = var.access_log_storage_account_allow_ips
  }
  tags = {}
}

resource "azurerm_monitor_diagnostic_setting" "frontdoor_access_log" {
  name               = "${var.pjname}frontdooraccesslog"
  target_resource_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  storage_account_id = azurerm_storage_account.frontdoor_log_sa.id
  enabled_log {
    category = "FrontdoorAccessLog"
  }
  # enabled_log {
  #   category = "FrontdoorWebApplicationFirewallLog"
  #   enabled  = false
  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }

  enabled_metric {
    category = "AllMetrics"
  }
}
