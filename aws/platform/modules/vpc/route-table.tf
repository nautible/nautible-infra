resource "aws_route" "private_route" {
  count                  = var.nat_instance_type != null && length(module.vpc.private_route_table_ids) > 0 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = element(module.vpc.private_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance[0].primary_network_interface_id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = var.nat_instance_type != null && length(module.vpc.private_route_table_ids) > 0 ? length(module.vpc.private_route_table_ids) : 0
  subnet_id      = element(module.vpc.private_subnets, count.index)
  route_table_id = element(module.vpc.private_route_table_ids, count.index)
}

