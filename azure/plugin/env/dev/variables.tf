# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}
# auth variables。authのpluginを利用する場合は値を設定する
variable "auth_variables" {
  # default = "" # auth pluginを利用しない場合。
  default = {
    # postgresql variables
    postgres = {
      version               = "13"
      sku_name              = "B_Standard_B1ms"
      storage_mb            = 32768 # 32G
      backup_retention_days = 7
      subnet_cidr           = "192.172.0.0/24"
      subnet_name           = "authpostgresqlpriavtesubnet"
      zone                  = "1"
    }
  }
}

