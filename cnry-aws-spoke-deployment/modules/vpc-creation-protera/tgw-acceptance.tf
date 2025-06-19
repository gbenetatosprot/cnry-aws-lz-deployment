################################################################################
# Accept TGW from RAM
################################################################################

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  count     = var.create_accepter ? 1 : 0
  share_arn = var.ram_share_arn
}

################################################################################
# Workaround: Trigger after RAM share is accepted
################################################################################

resource "null_resource" "tgw_ready" {
  count = var.create_accepter ? 1 : 0

  triggers = {
    accepted = aws_ram_resource_share_accepter.receiver_accept[0].id
  }
}

################################################################################
# Get Shared TGW ID (only if attachment should be created and accepter is enabled)
################################################################################

data "aws_ec2_transit_gateway" "shared" {
  count = var.create_accepter && var.attachment_creation ? 1 : 0

  filter {
    name   = "state"
    values = ["available"]
  }

  depends_on = [null_resource.tgw_ready]
}

################################################################################
# Create TGW Attachment (only if enabled)
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-spoke" {
  count = var.attachment_creation && var.create_accepter ? 1 : 0

  subnet_ids = aws_subnet.private[*].id
  vpc_id     = aws_vpc.this[0].id

  transit_gateway_id = data.aws_ec2_transit_gateway.shared[0].id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"

  tags = {
    Name = "securityVPC-Attach"
  }
}