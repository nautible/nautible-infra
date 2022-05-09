output "zone_name" {
  value = keys(module.zones.route53_zone_zone_id)[0]
}

output "zone_id" {
  value = module.zones.route53_zone_zone_id[keys(module.zones.route53_zone_zone_id)[0]]
}

output "private_zone_name" {
  value = keys(module.zones.route53_zone_zone_id)[1]
}

output "private_zone_id" {
  value = module.zones.route53_zone_zone_id[keys(module.zones.route53_zone_zone_id)[1]]
}