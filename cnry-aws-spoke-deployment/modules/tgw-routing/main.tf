################################################################################
# Route to TGW from Public Route Tables
################################################################################

resource "aws_route" "public_tgw" {
  count = var.default_tgw_route && length(var.public-rt) > 0 ? length(var.public-rt) : 0

  route_table_id         = var.public-rt[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

################################################################################
# Route to TGW from Private Route Tables
################################################################################

resource "aws_route" "private_tgw" {
  count = var.default_tgw_route && length(var.private-rt) > 0 ? length(var.private-rt) : 0

  route_table_id         = var.private-rt[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

################################################################################
# Route to TGW from Staging Route Tables
################################################################################

resource "aws_route" "staging_tgw" {
  count = var.default_staging_tgw && length(var.staging-rt) > 0 ? length(var.staging-rt) : 0

  route_table_id         = var.staging-rt[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}