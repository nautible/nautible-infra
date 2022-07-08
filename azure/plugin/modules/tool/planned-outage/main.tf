provider "azurerm" {
  features {} // required but empty ok
}
resource "azurerm_resource_group" "plugin_planned_outage" {
  name     = "${var.pjname}pluginplannedoutage"
  location = var.location
}

resource "azurerm_automation_account" "plugin_planned_outage_account" {
  name                = "${var.pjname}pluginplannedoutage"
  location            = azurerm_resource_group.plugin_planned_outage.location
  resource_group_name = azurerm_resource_group.plugin_planned_outage.name
  sku_name            = "Basic"
  tags                = {}
}

data "local_file" "auth_postgresql_start_stop_ps" {
  filename = "${path.module}/auth-postgresql-start-stop.ps1"
}

resource "azurerm_automation_runbook" "auth_postgresql_start_stop" {
  name                    = "authpostgresqlstartstop"
  location                = azurerm_resource_group.plugin_planned_outage.location
  resource_group_name     = azurerm_resource_group.plugin_planned_outage.name
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "authpostgresqlstartstop"
  runbook_type            = "PowerShell"

  content = data.local_file.auth_postgresql_start_stop_ps.content
}

resource "azurerm_automation_schedule" "auth_postgresql_start_schedule" {
  name                    = "authpostgresqlstartschedule"
  resource_group_name     = azurerm_resource_group.plugin_planned_outage.name
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Asia/Tokyo"
  start_time              = var.auth_postgresql_start_schedule_time
  week_days               = var.auth_postgresql_start_stop_schedule_weekdays
}

resource "azurerm_automation_schedule" "auth_postgresql_stop_schedule" {
  name                    = "authpostgresqlstopschedule"
  resource_group_name     = azurerm_resource_group.plugin_planned_outage.name
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
  resource_group_name     = azurerm_resource_group.plugin_planned_outage.name
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.auth_postgresql_start_schedule.name
  runbook_name            = azurerm_automation_runbook.auth_postgresql_start_stop.name

  parameters = {
    subscriptionid    = data.azurerm_subscription.current.subscription_id
    resourcegroupname = var.auth_postgresql_rg_name
    resourcename      = var.auth_postgresql_resource_name
    action            = "start"
  }
}

resource "azurerm_automation_job_schedule" "auth_postgresql_stop_job_schedule" {
  resource_group_name     = azurerm_resource_group.plugin_planned_outage.name
  automation_account_name = azurerm_automation_account.plugin_planned_outage_account.name
  schedule_name           = azurerm_automation_schedule.auth_postgresql_stop_schedule.name
  runbook_name            = azurerm_automation_runbook.auth_postgresql_start_stop.name

  parameters = {
    subscriptionid    = data.azurerm_subscription.current.subscription_id
    resourcegroupname = var.auth_postgresql_rg_name
    resourcename      = var.auth_postgresql_resource_name
    action            = "stop"
  }
}
