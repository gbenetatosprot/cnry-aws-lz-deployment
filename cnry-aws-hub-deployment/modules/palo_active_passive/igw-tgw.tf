#----------------------------------------------------------------------------------------------------------------------
# TGW 
#----------------------------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "main_tgw" {
  description                                           = "TGW"
  auto_accept_shared_attachments                        = "enable"
  default_route_table_association                       = "disable"
  default_route_table_propagation                       = "disable"
  tags = {
   Name                                                 = join("", [var.coid, "-", var.aws_region, "-TGW"])
  }
}


#----------------------------------------------------------------------------------------------------------------------
# TGW Attachment - Security VPC
#----------------------------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-main" {
  depends_on                                            = [aws_subnet.TGW,aws_ec2_transit_gateway.main_tgw]
  subnet_ids                                            = [aws_subnet.TGW.id]
  transit_gateway_id                                    = aws_ec2_transit_gateway.main_tgw.id
  transit_gateway_default_route_table_association       = false
  transit_gateway_default_route_table_propagation       = false
  vpc_id                                                = aws_vpc.main_vpc.id
  appliance_mode_support                                = "enable"
  tags = {
   Name                                                 = join("", [var.coid, "-", var.aws_region, "-securityVPC-Attach"])
  }
}

#----------------------------------------------------------------------------------------------------------------------
# IGW
#----------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "main_igw" {
  depends_on                                            = [aws_ec2_transit_gateway.main_tgw,aws_internet_gateway.main_igw]
  vpc_id                                                = aws_vpc.main_vpc.id
  tags = {
    Name                                                = join("", [var.coid, "-", var.aws_region, "-IGW"])
  }
}