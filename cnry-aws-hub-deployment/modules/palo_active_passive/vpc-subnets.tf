#----------------------------------------------------------------------------------------------------------------------
# Security VPC - Creation
#----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main_vpc" {
  cidr_block       					            = var.hub_address_space[0]
  tags = {
    Name                                        =  join("", [var.coid, "-", var.aws_region, "-vpc00-fw-vpc"])
  }
}

#----------------------------------------------------------------------------------------------------------------------
# Security VPC - Subnet Creation
#----------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                                        = aws_vpc.main_vpc.id
  cidr_block                                    = var.public_space_prefix[0]
  availability_zone                             = var.aws_availability_zone
  map_public_ip_on_launch                       = false
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-Public", "-", "subnet"])
  }
}

resource "aws_subnet" "Private" {
  vpc_id                                        = aws_vpc.main_vpc.id
  cidr_block                                    = var.private_space_prefix[0]
  availability_zone                             = var.aws_availability_zone
  map_public_ip_on_launch                       = false
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-Private", "-", "subnet"])
  }
}

resource "aws_subnet" "MNG" {
  vpc_id                                        = aws_vpc.main_vpc.id
  cidr_block                                    = var.mgmt_space_prefix[0]
  availability_zone                             = var.aws_availability_zone
  map_public_ip_on_launch                       = false
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-Management", "-", "subnet"])
  }
}

resource "aws_subnet" "TGW" {
  vpc_id                                        = aws_vpc.main_vpc.id
  cidr_block                                    = var.tgw_space_prefix[0]
  availability_zone                             = var.aws_availability_zone
  map_public_ip_on_launch                       = false
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-TGW", "-", "subnet"])
  }
}

resource "aws_subnet" "ha" {
  vpc_id                                        = aws_vpc.main_vpc.id
  cidr_block                                    = var.ha2_space_prefix[0]
  availability_zone                             = var.aws_availability_zone
  map_public_ip_on_launch                       = false
  tags = {
    Name                                        = join("", [var.coid, "-", var.aws_region, "-HA-subnet"])
  }
}