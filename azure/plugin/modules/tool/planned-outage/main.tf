provider "azurerm" {
  features {} // required but empty ok
}

resource "azurerm_automation_account" "plugin_planned_outage_account" {
  name                = "${var.pjname}pluginplannedoutage"
  location            = var.location
  resource_group_name = var.pjname
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
  tags = {}
}

resource "azurerm_role_assignment" "automation_account_ra" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.plugin_planned_outage_account.identity[0].principal_id
}

data "local_file" "auth_postgresql_start_stop_ps" {
  filename = "${path.module}/auth-postgresql-start-stop.ps1"
}

resource "azurerm_automation_runbook" "auth_postgresql_start_stop" {
  name                    = "authpostgresqlstartstop"
  location                = var.location
  resource_group_name     = var.pjname
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "authpostgresqlstartstop"
  runbook_type            = "PowerShell"

  content = data.local_file.auth_postgresql_start_stop_ps.content
}

resource "azurerm_automation_schedule" "auth_postgresql_start_schedule" {
  name                    = "authpostgresqlstartschedule"
  resource_group_name     = var.pjname
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.auth_postgresql_start_schedule_time
  week_days               = var.auth_postgresql_start_stop_schedule_weekdays
}

resource "azurerm_automation_schedule" "auth_postgresql_stop_schedule" {
  name                    = "authpostgresqlstopschedule"
  resource_group_name     = var.pjname
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.auth_postgresql_stop_schedule_time
  week_days               = var.auth_postgresql_start_stop_schedule_weekdays
}

data "azurerm_subscription" "current" {
}

resource "azurerm_automation_job_schedule" "auth_postgresql_start_job_schedule" {
  resource_group_name     = var.pjname
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.auth_postgresql_start_schedule.name
  runbook_name            = azurerm_automation_runbook.auth_postgresql_start_stop.name

  parameters = {
    subscriptionid = data.azurerm_subscription.current.subscription_id
    action         = "start"
  }
}

resource "azurerm_automation_job_schedule" "auth_postgresql_stop_job_schedule" {
  resource_group_name     = var.pjname
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.auth_postgresql_stop_schedule.name
  runbook_name            = azurerm_automation_runbook.auth_postgresql_start_stop.name

  parameters = {
    subscriptionid = data.azurerm_subscription.current.subscription_id
    action         = "stop"
  }
}
