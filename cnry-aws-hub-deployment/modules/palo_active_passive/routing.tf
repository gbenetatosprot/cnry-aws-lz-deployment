#----------------------------------------------------------------------------------------------------------------------
# SECURITY VPC - Route Tables
#----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "mgmt_rt" {
  depends_on                                    = [aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_vpn_connection.Oakbrook,aws_ec2_transit_gateway_vpc_attachment.tgw-main]
  vpc_id                                        = aws_vpc.main_vpc.id
  
  route {
    cidr_block                                  = "0.0.0.0/0"
    gateway_id                                  = aws_internet_gateway.main_igw.id
  }
  
  route {
    cidr_block                                  = "10.159.94.0/23"
    gateway_id                                  = aws_ec2_transit_gateway.main_tgw.id
  }
  
   route {
    cidr_block                                  = "100.70.0.0/15"
    gateway_id                                  = aws_ec2_transit_gateway.main_tgw.id
  }
  
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-management-rt"])
  }
}

resource "aws_route_table_association" "mgmt" {
  depends_on                                    = [aws_route_table.mgmt_rt,aws_ec2_transit_gateway.main_tgw]
  subnet_id                                     = aws_subnet.MNG.id
  route_table_id                                = aws_route_table.mgmt_rt.id
}

resource "aws_route_table" "private_rt" {
  depends_on                                    = [aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_vpn_connection.Oakbrook,aws_ec2_transit_gateway_vpc_attachment.tgw-main]
  vpc_id                                        = aws_vpc.main_vpc.id
  
  route {
    cidr_block                                  = "0.0.0.0/0"
    gateway_id                                  = aws_ec2_transit_gateway.main_tgw.id
  }
  
  
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-private-rt"])
  }
}

resource "aws_route_table_association" "prvt" {
  depends_on                                    = [aws_route_table.private_rt]
  subnet_id                                     = aws_subnet.Private.id
  route_table_id                                = aws_route_table.private_rt.id
}

resource "aws_route_table" "public_rt" {
  vpc_id                                        = aws_vpc.main_vpc.id
  
  route {
    cidr_block                                  = "0.0.0.0/0"
    gateway_id                                  = aws_internet_gateway.main_igw.id
  }
  
  
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-public-rt"])
  }
}

resource "aws_route_table_association" "public" {
  depends_on                                    = [aws_route_table.public_rt]
  subnet_id                                     = aws_subnet.public.id
  route_table_id                                = aws_route_table.public_rt.id
}

resource "aws_route_table" "tgw1_rt" {
  vpc_id                                        =  aws_vpc.main_vpc.id
  route {
    cidr_block                                  = "0.0.0.0/0"
    network_interface_id                        = aws_network_interface.private1.id
  }
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-tgw-rt"])
  }
}

resource "aws_route_table_association" "tgw1" {
  depends_on                                    = [aws_route_table.tgw1_rt]
  subnet_id                                     = aws_subnet.TGW.id
  route_table_id                                = aws_route_table.tgw1_rt.id
}

resource "aws_route_table" "ha_rt" {
  vpc_id                                        =  aws_vpc.main_vpc.id
  
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-ha-rt"])
  }
}

resource "aws_route_table_association" "ha1" {
  depends_on                                    = [aws_route_table.ha_rt]
  subnet_id                                     = aws_subnet.ha.id
  route_table_id                                = aws_route_table.ha_rt.id
}


#----------------------------------------------------------------------------------------------------------------------
# TGW - Route Tables
#----------------------------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "inboundvpc" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw]
  transit_gateway_id                            = aws_ec2_transit_gateway.main_tgw.id
  tags = {
   Name                                                 = join("", [var.coid, "-Inbound-VPC"])
  }
}

resource "aws_ec2_transit_gateway_route_table" "inboundvpn" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw]
  transit_gateway_id                            = aws_ec2_transit_gateway.main_tgw.id
  tags = {
   Name                                                 = join("", [var.coid, "-Inbound-VPN"])
  }
}

resource "aws_ec2_transit_gateway_route_table" "outbound" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw]
  transit_gateway_id                            = aws_ec2_transit_gateway.main_tgw.id
  tags = {
   Name                                                 = join("", [var.coid, "-Outbound"])
  }
}

#----------------------------------------------------------------------------------------------------------------------
# TGW - Route Tables Associations
#----------------------------------------------------------------------------------------------------------------------

# Associate Security VPC with Outbound

resource "aws_ec2_transit_gateway_route_table_association" "associate_vpc" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpc]
  transit_gateway_attachment_id                 = aws_ec2_transit_gateway_vpc_attachment.tgw-main.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.outbound.id
}

# Associate VPN with Inbound VPN

resource "aws_ec2_transit_gateway_route_table_association" "associate_vpn" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  transit_gateway_attachment_id                 = data.aws_ec2_transit_gateway_vpn_attachment.oak_attach.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.inboundvpn.id
}


#----------------------------------------------------------------------------------------------------------------------
# TGW - Route Tables Routes
#----------------------------------------------------------------------------------------------------------------------


resource "aws_ec2_transit_gateway_route" "oak_vpn_1" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  destination_cidr_block                        = "10.159.94.0/23"
  transit_gateway_attachment_id                 = data.aws_ec2_transit_gateway_vpn_attachment.oak_attach.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.outbound.id
  blackhole                                     = false
}

resource "aws_ec2_transit_gateway_route" "oak_vpn_2" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  destination_cidr_block                        = "100.70.0.0/15"
  transit_gateway_attachment_id                 = data.aws_ec2_transit_gateway_vpn_attachment.oak_attach.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.outbound.id
  blackhole                                     = false
}

resource "aws_ec2_transit_gateway_route" "firewall_1" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  destination_cidr_block                        = "0.0.0.0/0"
  transit_gateway_attachment_id                 = aws_ec2_transit_gateway_vpc_attachment.tgw-main.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.inboundvpn.id
  blackhole                                     = false
}

resource "aws_ec2_transit_gateway_route" "firewall_2" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  destination_cidr_block                        = "0.0.0.0/0"
  transit_gateway_attachment_id                 = aws_ec2_transit_gateway_vpc_attachment.tgw-main.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.inboundvpc.id
  blackhole                                     = false
}

resource "aws_ec2_transit_gateway_route" "vpc_cidr" {
  depends_on                                    = [aws_vpn_connection.Oakbrook, aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  destination_cidr_block                        = var.hub_address_space[0]
  transit_gateway_attachment_id                 = aws_ec2_transit_gateway_vpc_attachment.tgw-main.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.outbound.id
  blackhole                                     = false
}