resource "azurerm_frontdoor" "frontdoor" {
  name                = "${var.pjname}frontdoor"
  resource_group_name = var.rgname
  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
  }

  backend_pool {
    name                = "${var.pjname}staticwebbp"
    load_balancing_name = "${var.pjname}staticwebbplb"
    health_probe_name   = "${var.pjname}staticwebbphp"

    backend {
      host_header = var.static_web_primary_web_host
      address     = var.static_web_primary_web_host
      http_port   = 80
      https_port  = 443
    }
  }

  dynamic "backend_pool" {
    for_each = var.istio_ig_lb_ip != null ? ["true"] : []
    content {
      name                = "${var.pjname}apibp"
      load_balancing_name = "${var.pjname}apibplb"
      health_probe_name   = "${var.pjname}apibphp"

      backend {
        host_header = var.istio_ig_lb_ip
        address     = var.istio_ig_lb_ip
        http_port   = 80
        https_port  = 443
      }
    }
  }

  routing_rule {
    name               = "${var.pjname}staticwebbprr"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["${var.pjname}frontdoor"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "${var.pjname}staticwebbp"
    }
  }

  dynamic "routing_rule" {
    for_each = var.istio_ig_lb_ip != null ? ["true"] : []
    content {
      name               = "${var.pjname}apibprr"
      accepted_protocols = ["Https"]
      patterns_to_match  = [var.service_api_path_pattern]
      frontend_endpoints = ["${var.pjname}frontdoor"]
      forwarding_configuration {
        forwarding_protocol = "HttpOnly"
        backend_pool_name   = "${var.pjname}apibp"
      }
    }
  }

  backend_pool_health_probe {
    name         = "${var.pjname}staticwebbphp"
    protocol     = "Https"
    probe_method = "GET"
  }

  dynamic "backend_pool_health_probe" {
    for_each = var.istio_ig_lb_ip != null ? ["true"] : []
    content {
      name         = "${var.pjname}apibphp"
      protocol     = "Http"
      probe_method = "GET"
    }
  }

  backend_pool_load_balancing {
    name = "${var.pjname}staticwebbplb"
  }

  dynamic "backend_pool_load_balancing" {
    for_each = var.istio_ig_lb_ip != null ? ["true"] : []
    content {
      name = "${var.pjname}apibplb"
    }
  }

  frontend_endpoint {
    name                     = "${var.pjname}frontdoor"
    host_name                = "${var.pjname}frontdoor.azurefd.net"
    session_affinity_enabled = var.front_door_session_affinity_enabled
  }
  tags = {}
}

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
  target_resource_id = azurerm_frontdoor.frontdoor.id
  storage_account_id = azurerm_storage_account.frontdoor_log_sa.id
  enabled_log {
    category = "FrontdoorAccessLog"
    retention_policy {
      enabled = true
      days    = 7
    }
  }
  # enabled_log {
  #   category = "FrontdoorWebApplicationFirewallLog"
  #   enabled  = false
  #   retention_policy {
  #     enabled = false
  #     days    = 0
  #   }
  # }

  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
