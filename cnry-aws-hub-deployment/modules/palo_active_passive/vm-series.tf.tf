#----------------------------------------------------------------------------------------------------------------------
# VM-Series Palo AMI
#----------------------------------------------------------------------------------------------------------------------


data "aws_ami" "firewall" {
  most_recent                               = true
  owners                                    = ["aws-marketplace"]

  filter {
    name                                    = "name"
    values                                  = ["PA-VM-AWS-11.1.6-h7-7064e142-2859-40a4-ab62-8b0996b842e9*"]
  }
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - VM Creation - First Firewall
#----------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "vm1" {
  ami                                       = data.aws_ami.firewall.id
  instance_type                             = var.instance_type
  availability_zone                         = var.aws_availability_zone
  key_name                                  = "firewall"
  private_ip                                = cidrhost(var.hub_address_space[0], 4)
  iam_instance_profile			            = aws_iam_instance_profile.ec2_profile.name
  subnet_id                                 = aws_subnet.MNG.id
  vpc_security_group_ids                    = [aws_security_group.MGMT_sg.id]
  disable_api_termination                   = false
  instance_initiated_shutdown_behavior      = "stop"
  ebs_optimized                             = true
  source_dest_check                         = false
  monitoring                                = false
  tags = {

    Name                                    = join ("", [var.coid, "-AWS", var.location_short, "pa00-a"])
    protera_type                            = "network appliance"
    protera_coid                            = var.coid
    protera_apid                            = "PA"
    protera_env                             = var.environment
    protera_desc                            = "Palo Alto Virtual Firewall"
  }

  root_block_device {
    delete_on_termination                   = true
  }

}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - VM Creation - Second Firewall
#----------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "vm2" {
  ami                                       = data.aws_ami.firewall.id
  instance_type                             = var.instance_type
  availability_zone                         = var.aws_availability_zone
  key_name                                  = "firewall"
  private_ip                                = cidrhost(var.hub_address_space[0], 5)
  iam_instance_profile			            = aws_iam_instance_profile.ec2_profile.name
  subnet_id                                 = aws_subnet.MNG.id
  vpc_security_group_ids                    = [aws_security_group.MGMT_sg.id]
  disable_api_termination                   = false
  instance_initiated_shutdown_behavior      = "stop"
  ebs_optimized                             = true
  monitoring                                = false
  depends_on                                = [aws_instance.vm1]
  source_dest_check                         = false
  tags = {

    Name                                    = join ("", [var.coid, "-AWS", var.location_short, "pa00-b"])
    protera_type                            = "network appliance"
    protera_coid                            = var.coid
    protera_apid                            = "PA"
    protera_env                             = var.environment
    protera_desc                            = "Palo Alto Virtual Firewall"
  }

  root_block_device {
    delete_on_termination                   = true
  }
}


#----------------------------------------------------------------------------------------------------------------------
# VM-Series - VM Creation - Secondary Interfaces - HA
#----------------------------------------------------------------------------------------------------------------------

resource "aws_network_interface" "ha1" {
  subnet_id                                 = aws_subnet.ha.id
  private_ips                               = [cidrhost(var.hub_address_space[0], 36) ]
  security_groups                           = [aws_security_group.private_sg.id]
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_eip.mng1]
  attachment {
    instance                                = aws_instance.vm1.id
	device_index                              = 1
  }
}

resource "aws_network_interface" "ha2" {
  subnet_id                                 = aws_subnet.ha.id
  private_ips                               = [cidrhost(var.hub_address_space[0], 37) ]
  security_groups                           = [aws_security_group.private_sg.id]
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_eip.mng1]
  attachment {
    instance                                = aws_instance.vm2.id
	device_index                              = 1
  }
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - VM Creation - Secondary Interfaces - Public
#----------------------------------------------------------------------------------------------------------------------

resource "aws_network_interface" "public1" {
  subnet_id                                 = aws_subnet.public.id
  private_ips                               = [cidrhost(var.hub_address_space[0], 132) ]
  security_groups                           = [aws_security_group.public_sg.id]
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_eip.mng1,aws_network_interface.ha2]	  

  attachment {
    instance                                = aws_instance.vm1.id
    device_index                            = 2
  }
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - VM Creation - Secondary Interfaces - Private
#----------------------------------------------------------------------------------------------------------------------

resource "aws_network_interface" "private1" {
  subnet_id                                 = aws_subnet.Private.id
  private_ips                               = [cidrhost(var.hub_address_space[0], 20) ]
  security_groups                           = [aws_security_group.private_sg.id]
  depends_on                                = [aws_instance.vm1,aws_internet_gateway.main_igw,aws_ec2_transit_gateway.main_tgw,aws_eip.mng1,aws_network_interface.public1]
  attachment {
    instance                                = aws_instance.vm1.id
	device_index                            = 3
  }
}