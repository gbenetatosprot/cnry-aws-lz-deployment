#----------------------------------------------------------------------------------------------------------------------
# HUB and Firewall Creation
#----------------------------------------------------------------------------------------------------------------------

module "palo-alto" {
  source = "./modules/palo_active_passive"

  coid                              = local.coid
  environment                       = local.environment
  location_short                    = local.location_short
  instance_type                     = local.instance_type

  #Subnet creation form VPC CIDR - Option 5 means /28 subnets if VPC is /23 AND option 4 means /28 if VPC is /24

  hub_address_space                 = local.hub_address_space
  mgmt_space_prefix                 = [cidrsubnet(local.hub_address_space[0], 4, 0)]
  public_space_prefix               = [cidrsubnet(local.hub_address_space[0], 4, 8)]
  private_space_prefix              = [cidrsubnet(local.hub_address_space[0], 4, 1)]
  ha2_space_prefix                  = [cidrsubnet(local.hub_address_space[0], 4, 2)]
  tgw_space_prefix                  = [cidrsubnet(local.hub_address_space[0], 4, 3)]
  aws_region                        = local.aws_region
  aws_availability_zone             = local.aws_availability_zone

}

#----------------------------------------------------------------------------------------------------------------------
# Share TGW to Spoke Accounts
#----------------------------------------------------------------------------------------------------------------------

# Create the resource share

resource "aws_ram_resource_share" "tgw_share" {
  name                              = "shared-tgw-to-spoke"
  allow_external_principals         = true
  depends_on                        = [module.palo-alto]
}

# Create the shared resource association

resource "aws_ram_resource_association" "tgw_assoc" {
  resource_arn                      = module.palo-alto.tgw_arn
  resource_share_arn                = aws_ram_resource_share.tgw_share.arn
}

# Create the shared Principal association - Update the variable to add/remove

resource "aws_ram_principal_association" "share_to_accounts" {
  for_each                          = toset(var.ram_principals)
  principal                         = each.key
  resource_share_arn                = aws_ram_resource_share.tgw_share.arn
  depends_on                        = [module.palo-alto]
}