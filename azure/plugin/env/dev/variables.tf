# Project name
variable "pjname" {
  default = "nautibledev"
}
# location
variable "location" {
  default = "japaneast"
}
# authのvariables。authのpluginを利用する場合は値を設定する
variable "auth" {
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
variable "auth_postgres_administrator_login" {
  description = "認証pluginで利用するDBのadminユーザーID。初回のみ入力する。初回以外の場合、または認証pluginを利用しない場合はEnterで入力をスキップする。"
}
variable "auth_postgres_administrator_password" {
  description = "認証pluginで利用するDBのパスワード。初回のみ入力する。初回以外の場合、または認証pluginを利用しない場合はEnterで入力をスキップする。"
}


