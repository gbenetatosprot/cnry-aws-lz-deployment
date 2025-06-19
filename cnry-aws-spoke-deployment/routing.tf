# ################################################################################
# # Routing for VPC - Run AFTER Attachment is accepted from hub
# ################################################################################

# # Route to TGW for public route table (if it exists)
# resource "aws_route" "pubrr" {
#   count = module.vpc_module.public_route_table_ids != [] ? 1 : 0

#   route_table_id         = module.vpc_module.public_route_table_ids[0]
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = var.transit_gateway_id
# }

