################################################################################
# Accept TGW from ARM
################################################################################

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  count     = var.create_accepter ? 1 : 0
  share_arn = var.ram_share_arn
}

################################################################################
# Get Shared TGW ID
################################################################################

data "aws_ec2_transit_gateway" "shared" {
  filter {
    name   = "state"
    values = ["available"]
  }
  depends_on = [aws_ram_resource_share_accepter.receiver_accept]
}

locals {
  tgw_id_available = can(data.aws_ec2_transit_gateway.shared.id)
}

################################################################################
# Create TGW Attachment
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-spoke" {
  count = var.attachment_creation ? 1 : 0

  subnet_ids      = aws_subnet.private[*].id
  vpc_id          = aws_vpc.this[0].id

  transit_gateway_id = data.aws_ec2_transit_gateway.shared.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"

  tags = {
    Name = "securityVPC-Attach"
  }
}