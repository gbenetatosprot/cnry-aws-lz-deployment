#----------------------------------------------------------------------------------------------------------------------
# Security Groups for Security VPC
#----------------------------------------------------------------------------------------------------------------------

# Public Subnet SG

resource "aws_security_group" "public_sg" {
  name                                      = "public_sg"
  description                               = "public SG"
  vpc_id                                    = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each                                = var.rules_inbound_public_sg
    content {
      from_port                             = ingress.value["port"]
      to_port                               = ingress.value["port"]
      protocol                              = ingress.value["proto"]
      cidr_blocks                           = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each = var.rules_outbound_public_sg
    content {
      from_port                             = egress.value["port"]
      to_port                               = egress.value["port"]
      protocol                              = egress.value["proto"]
      cidr_blocks                           = egress.value["cidr_block"]
    }
  }
  tags = {
    Name                                            = join("", [var.coid, "-", var.aws_region, "-public-SG"])
  }
}

# Private Subnet SG

 resource "aws_security_group" "private_sg" {
  name                                         = "private_sg"
  description                                  = "Private SG"
  vpc_id                                       = aws_vpc.main_vpc.id


  dynamic "ingress" {
    for_each                                   = var.rules_inbound_private_sg
    content {
      from_port                                 = ingress.value["port"]
      to_port                                   = ingress.value["port"]
      protocol                                  = ingress.value["proto"]
      cidr_blocks                               = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each                                    = var.rules_outbound_private_sg
    content {
      from_port                                 = egress.value["port"]
      to_port                                   = egress.value["port"]
      protocol                                  = egress.value["proto"]
      cidr_blocks                               = egress.value["cidr_block"]
    }
  }
  tags = {
    Name                                            = join("", [var.coid, "-", var.aws_region, "-private-SG"])
  }
} 

# Management Subnet SG

  resource "aws_security_group" "MGMT_sg" {
  name                                          = "MGMT_sg"
  description                                   = "MGMT SG"
  vpc_id                                        = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each                                    = var.rules_inbound_mgmt_sg
    content {
      from_port                                 = ingress.value["port"]
      to_port                                   = ingress.value["port"]
      protocol                                  = ingress.value["proto"]
      cidr_blocks                               = ingress.value["cidr_block"]
    }
  }

  egress {
    from_port                                  = 0
    to_port                                    = 0
    protocol                                   = "-1"
    prefix_list_ids                            = [aws_ec2_managed_prefix_list.ha-interfaces.id]
  }

  egress {
    from_port                                  = 0
    to_port                                    = 0
    protocol                                   = "-1"
    prefix_list_ids                            = [aws_ec2_managed_prefix_list.internet-pl.id]
  }
  dynamic "egress" {
    for_each                                    = var.rules_outbound_mgmt_sg
    content {
      from_port                                 = egress.value["port"]
      to_port                                   = egress.value["port"]
      protocol                                  = egress.value["proto"]
      cidr_blocks                               = egress.value["cidr_block"]
    }
  }
  tags = {
    Name                                            = join("", [var.coid, "-", var.aws_region, "-management-SG"])
  }
}