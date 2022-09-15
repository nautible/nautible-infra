output "vnet" {
  value = module.nautible_azure_platform.vnet
}
output "aks" {
  value = module.nautible_azure_platform.aks
}
output "app" {
  value = module.nautible_azure_platform.app
}
output "dns" {
  value = module.nautible_azure_platform.dns
}