################################################################################
# VPC Creation - SPOKE
################################################################################

module "vpc1" {
  source  = "./modules/vpc-creation-protera"

  name            = "bene-vpc-1"
  cidr            = "10.160.10.0/23"
  azs             = ["eu-west-3a", "eu-west-3b"]
  private_subnets = ["10.160.10.0/25", "10.160.11.0/25"]
  public_subnets  = ["10.160.10.128/26", "10.160.11.128/26"]
  staging_subnets = ["10.160.10.192/27"]

  private_subnet_names = ["Private-AZ1", "Private-AZ2"]
  public_subnet_names = ["Public-AZ1", "Public-AZ2"]
  staging_subnet_names = ["Staging-Subnet-AZ1-PRV"]

  enable_nat_gateway = false


  enable_dns_hostnames = true
  enable_dns_support   = true

  tgw_share = true

  ram_principals = [503659244423]
  ram_share_arn = "arn:aws:ram:eu-west-3:706210432878:resource-share/a2a577e7-30a4-4dad-b8c7-f14f62767e29"

  create_staging_subnet_route_table = true

  attachment_creation = true
}

module "vpc2" {
  source  = "./modules/vpc-creation-protera"

  name            = "bene-vpc-2"
  cidr            = "192.168.50.0/23"
  azs             = ["eu-west-3a", "eu-west-3b"]
  private_subnets = ["192.168.50.0/25", "192.168.51.0/25"]
  public_subnets  = ["192.168.50.128/26", "192.168.51.128/26"]
  staging_subnets = ["192.168.50.192/27"]

  private_subnet_names = ["Private-AZ1", "Private-AZ2"]
  public_subnet_names = ["Public-AZ1", "Public-AZ2"]
  staging_subnet_names = ["Staging-Subnet-AZ1-PRV"]

  enable_nat_gateway = false


  enable_dns_hostnames = true
  enable_dns_support   = true

  tgw_share = false

  ram_principals = [503659244423]
  ram_share_arn = "arn:aws:ram:eu-west-3:706210432878:resource-share/a2a577e7-30a4-4dad-b8c7-f14f62767e29"

  create_staging_subnet_route_table = true
  depends_on = [module.vpc1]

  attachment_creation = true
}