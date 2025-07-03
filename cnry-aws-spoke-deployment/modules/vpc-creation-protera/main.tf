
################################################################################
# VPC
################################################################################

# Creates VPC onlyh if create_vpc is true. Default value is true

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block                           = var.cidr

  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support

  tags = {
  Name = var.vpc_name
}
}

# Adds CIDR (secodanry) to VPC

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count                               = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  # Do not turn this into `local.vpc_id`
  vpc_id                              = aws_vpc.this[0].id

  cidr_block                          = element(var.secondary_cidr_blocks, count.index)
}

################################################################################
# DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  count = local.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name                       = var.dhcp_options_domain_name
  domain_name_servers               = var.dhcp_options_domain_name_servers
  ntp_servers                       = var.dhcp_options_ntp_servers
  netbios_name_servers              = var.dhcp_options_netbios_name_servers
  netbios_node_type                 = var.dhcp_options_netbios_node_type

  tags = {
  "Name" = lower(join("-", [local.coid, local.location_short, local.protera_env, local.protera_type, "dhcp"]))
}
}

resource "aws_vpc_dhcp_options_association" "this" {
  count                             = local.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id                            = local.vpc_id
  dhcp_options_id                   = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Publiс Subnets
################################################################################

#Using this local syntax to avoid issue during TF plan, when there is no public subnets created

locals {
  create_public_subnets             = local.create_vpc && local.len_public_subnets > 0
}

#Create Public subnets. For AZ BOTH, Amazon backend and user formats are acceptable. Amazon format (eg use1-az1) MUST be used in case we have Priavate Link requirements

resource "aws_subnet" "public" {
  count = local.create_public_subnets && (!var.one_nat_gateway_per_az || local.len_public_subnets >= length(var.azs)) ? local.len_public_subnets : 0

  availability_zone                              = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                                     = element(var.public_subnets, count.index)
  enable_resource_name_dns_a_record_on_launch    = var.public_subnet_enable_resource_name_dns_a_record_on_launch
  map_public_ip_on_launch                        = var.map_public_ip_on_launch
  private_dns_hostname_type_on_launch            = var.public_subnet_private_dns_hostname_type_on_launch
  vpc_id                                         = local.vpc_id

  tags = {
      Name = try(
        var.public_subnet_names[count.index],
        format("${var.public_subnet_suffix}-%s", element(var.azs, count.index))
      )
    }
}

#Create Public Subnet routing tables - Local format is used to avoid issues when Public subnet are NOT created

locals {
  num_public_route_tables = var.create_multiple_public_route_tables ? local.len_public_subnets : 1
}

resource "aws_route_table" "public" {
  count = local.create_public_subnets ? local.num_public_route_tables : 0

  vpc_id = local.vpc_id

  tags = {
      "Name" = var.create_multiple_public_route_tables ? format(
        "${var.coid}-${var.coid}-${var.public_subnet_suffix}-%s",
        element(var.azs, count.index),
      ) : "${var.coid}-${var.coid}-${var.public_subnet_suffix}"
    }
}

#Associate public rt to Public subnets

resource "aws_route_table_association" "public" {
  count = local.create_public_subnets ? local.len_public_subnets : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, var.create_multiple_public_route_tables ? count.index : 0)
}

#Adds the default route to IGW for public subnets, ONLY if that is passed through the landingzone.tf

resource "aws_route" "public_internet_gateway" {
  count = (
    local.create_public_subnets &&
    var.create_igw &&
    var.public_default_route
  ) ? local.num_public_route_tables : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}


#Creates a Public SG
resource "aws_security_group" "public" {
  name        = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "public-sg"]))
  description = "Allow inbound RFC1918 and outbound all"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    description = "Allow from 10.0.0.0/8"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Allow from 172.16.0.0/12"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }

  ingress {
    description = "Allow from 192.168.0.0/16"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "public-sg"]))
  }
}

################################################################################
# Public Network ACLs
################################################################################

#Default ACL - Attached to all public Subnets - Different from Private so we can add workload specific rules

resource "aws_network_acl" "public" {
  count = local.create_public_subnets && var.public_dedicated_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.public[*].id

  tags = { "Name" = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "public-nacl"])) }
}

resource "aws_network_acl_rule" "public_inbound" {
  count = local.create_public_subnets && var.public_dedicated_network_acl ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = local.create_public_subnets && var.public_dedicated_network_acl ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}

################################################################################
# Private Subnets
################################################################################

#In local syntax to avoid the posibility of an error during TF Plan, in case we do not want the creation of private subnets

locals {
  create_private_subnets = local.create_vpc && local.len_private_subnets > 0
}

resource "aws_subnet" "private" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  availability_zone                              = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                                     = element(var.private_subnets, count.index)
  enable_resource_name_dns_a_record_on_launch    = var.private_subnet_enable_resource_name_dns_a_record_on_launch
  private_dns_hostname_type_on_launch            = var.private_subnet_private_dns_hostname_type_on_launch
  vpc_id                                         = local.vpc_id

  tags = {
      Name = try(
        var.private_subnet_names[count.index],
        format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
      )
    }
}

#Creates an empty Private subnet RT

resource "aws_route_table" "private" {
  count  = 1
  vpc_id = local.vpc_id

  tags = {
    Name = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "private-rt"]))
  }
}

#Associates the Private rt to Private subnets

resource "aws_route_table_association" "private" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

#Creates an SG for Private Subnets

resource "aws_security_group" "private" {
  name        = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "private-sg"]))
  description = "Allow inbound RFC1918 and outbound all"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    description = "Allow from 10.0.0.0/8"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Allow from 172.16.0.0/12"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }

  ingress {
    description = "Allow from 192.168.0.0/16"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "private-sg"]))
  }
}

################################################################################
# Private Network ACLs
################################################################################

#ACL creation. Local syntax is used to avoid issues during TF Plan, if no private subnets are needed

locals {
  create_private_network_acl = local.create_private_subnets && var.private_dedicated_network_acl
}

resource "aws_network_acl" "private" {
  count = local.create_private_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.private[*].id

  tags = { 
    "Name" = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "private-nacl"])) }
}

resource "aws_network_acl_rule" "private_inbound" {
  count = local.create_private_network_acl ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = local.create_private_network_acl ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}

################################################################################
# Staging Subnets
################################################################################

locals {
  create_staging_subnets     = local.create_vpc && local.len_staging_subnets > 0
  create_staging_route_table = local.create_staging_subnets && var.create_staging_subnet_route_table
}

#Create Staging subnets for DRS/AMS - if those are needed

resource "aws_subnet" "staging" {
  count = local.create_staging_subnets ? local.len_staging_subnets : 0

  availability_zone                              = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                                     = element(var.staging_subnets, count.index)
  enable_resource_name_dns_a_record_on_launch    = var.staging_subnet_enable_resource_name_dns_a_record_on_launch
  private_dns_hostname_type_on_launch            = var.staging_subnet_private_dns_hostname_type_on_launch
  vpc_id                                         = local.vpc_id

 tags = {
      Name = try(
        var.staging_subnet_names[count.index],
        format("${var.name}-${var.staging_subnet_suffix}-%s", element(var.azs, count.index))
      )
    }
}

#Create rt for staging subnet - Giving a separate RT helps to easily change between a public replication and a private replication

resource "aws_route_table" "staging" {
  count = local.create_staging_route_table ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "staging-rt"]))
  }
}

#Associate Staging rt to Staging subnets

resource "aws_route_table_association" "staging" {
  count = local.create_staging_subnets ? local.len_staging_subnets : 0

  subnet_id      = aws_subnet.staging[count.index].id
  route_table_id = aws_route_table.staging[0].id
}

#Create a IGW for public replication

resource "aws_route" "staging_internet_gateway" {
  count = (
    local.create_staging_route_table &&
    var.create_igw &&
    var.create_staging_internet_gateway_route &&
    !var.create_staging_nat_gateway_route &&
    var.default_route_staging
  ) ? 1 : 0

  route_table_id         = aws_route_table.staging[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#Create a NAT GW route - in case of no FW

resource "aws_route" "staging_nat_gateway" {
  count = (
    local.create_staging_route_table &&
    !var.create_staging_internet_gateway_route &&
    var.create_staging_nat_gateway_route &&
    var.enable_nat_gateway &&
    var.default_route_staging
  ) ? (var.single_nat_gateway ? 1 : local.len_staging_subnets) : 0

  route_table_id         = element(aws_route_table.staging[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

################################################################################
# staging Network ACLs
################################################################################

locals {
  create_staging_network_acl = local.create_staging_subnets && var.staging_dedicated_network_acl
}

#Create Staging subnets ACL

resource "aws_network_acl" "staging" {
  count = local.create_staging_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.staging[*].id

 tags = { 
  "Name" = lower(join("-", [ var.coid, var.location_short, var.protera_env, var.protera_type, "staging-nacl"]))
}
}

resource "aws_network_acl_rule" "staging_inbound" {
  count = local.create_staging_network_acl ? length(var.staging_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.staging[0].id

  egress          = false
  rule_number     = var.staging_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.staging_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.staging_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.staging_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.staging_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.staging_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.staging_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.staging_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "staging_outbound" {
  count = local.create_staging_network_acl ? length(var.staging_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.staging[0].id

  egress          = true
  rule_number     = var.staging_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.staging_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.staging_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.staging_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.staging_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.staging_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.staging_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.staging_outbound_acl_rules[count.index], "cidr_block", null)
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = local.create_public_subnets && var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "igw"]))
}

################################################################################
# NAT Gateway
################################################################################

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  nat_gateway_ips   = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat[*].id
}

#Create an EIP for NAT GW

resource "aws_eip" "nat" {
  count = local.create_vpc && var.enable_nat_gateway && !var.reuse_nat_ips ? local.nat_gateway_count : 0

  domain = "vpc"

  tags =  {
      "Name" = format(
        "${var.coid}-${var.region_short}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    }

  depends_on = [aws_internet_gateway.this]
}

#Create the NAT GW

resource "aws_nat_gateway" "this" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

#Add route to NAT GW

resource "aws_route" "private_nat_gateway" {
  count = local.create_vpc && var.enable_nat_gateway && var.create_private_nat_gateway_route ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

################################################################################
# VPC Gateway Endpoints
################################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id                    = local.vpc_id
  service_name              = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type         = "Gateway"
  route_table_ids           = concat(
    aws_route_table.public[*].id,
    aws_route_table.private[*].id
  )
  tags                      = {
    Name = lower(join("-", [var.coid, var.location_short, var.protera_env, var.protera_type, "s3-gw"]))
  }
}