#----------------------------------------------------------------------------------------------------------------------
# Project Locals
#----------------------------------------------------------------------------------------------------------------------

locals {
  coid                                      = var.protera_coid
  environment                               = var.protera_env
  location_short                            = var.protera_location_short
  aws_region                                = var.aws_region
  instance_type                             = var.instance_type
  aws_availability_zone                     = var.aws_availability_zone

  hub_address_space                         = var.hub_address
}