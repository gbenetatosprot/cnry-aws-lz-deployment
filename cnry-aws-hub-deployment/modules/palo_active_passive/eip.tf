#----------------------------------------------------------------------------------------------------------------------
# Elastic IP Creation (Public and Management)
#----------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "mng1" {
  vpc                                       = true
  tags = {
    Name                                    = join("", [var.coid, "-", var.aws_region, "-management-eip-1"])
  }
  instance                                  = aws_instance.vm1.id
  associate_with_private_ip                 = cidrhost(var.hub_address_space[0], 4)
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw]
}

resource "aws_eip" "mng2" {
  vpc                                       = true
  tags = {
    Name                                    = join("", [var.coid, "-", var.aws_region, "-management-eip-2"])
  }
  instance                                  = aws_instance.vm2.id
  associate_with_private_ip                 = cidrhost(var.hub_address_space[0], 5)
  depends_on                                = [aws_instance.vm2,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw]
}

resource "aws_eip" "pub1" {
  vpc                                       = true
  tags = {
    Name                                    = join("", [var.coid, "-", var.aws_region, "-public-eip"])
  }
  network_interface                         = aws_network_interface.public1.id
  associate_with_private_ip                 = cidrhost(var.hub_address_space[0], 132)
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw]
}