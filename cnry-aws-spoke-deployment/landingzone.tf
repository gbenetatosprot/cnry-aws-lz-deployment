################################################################################
# Get the Shared ARN of the TGW - Enable if there is a TGW share from hub
################################################################################

# data "terraform_remote_state" "ram_producer" {
#   backend = "remote"

#   config = {
#     organization = "gbenetatos_Org"
#     workspaces = {
#       name = "prot-cnry-aws-hub-deployment"
#     }
#   }
# }

################################################################################
# VPC Creation - SPOKE
################################################################################

module "vpc1" {
  source  = "./modules/vpc-creation-protera"

#Basic info
  region          = var.region
  vpc_name        = lower(join("-", [local.coid, local.region_short, local.protera_env, local.protera_type, "vpc"]))
  coid            = local.coid
  protera_env     = local.protera_env
  protera_desc    = local.protera_desc
  protera_status  = local.protera_status
  region_short    = local.region_short
  protera_type    = local.protera_type


  #VPC IP schema
  cidr            = "10.160.10.0/23"
  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["10.160.10.0/25", "10.160.11.0/25"]
  public_subnets  = ["10.160.10.128/26", "10.160.11.128/26"]

  private_subnet_names =  [
  "${local.coid}-${local.region_short}-${local.protera_type}-private-az1",
  "${local.coid}-${local.region_short}-${local.protera_type}-private-az2"
]
  public_subnet_names = [ 
  "${local.coid}-${local.region_short}-${local.protera_type}-public-az1", 
  "${local.coid}-${local.region_short}-${local.protera_type}-public-az2" 
]


#Staging Subnet Configuration
  staging_subnets = ["10.160.10.192/27"]
  staging_subnet_names = ["${local.coid}-${local.region_short}-${local.protera_type}-staging-az1"]
  create_staging_subnet_route_table = true
  create_staging_nat_gateway_route = false
  default_route_staging = true
  create_staging_internet_gateway_route = true

#NAT GW Configuration
  enable_nat_gateway = true
  single_nat_gateway = true

#IGW COnfiguration
  create_igw = false
  public_default_route = false

#VPC DNS Configuration - Important for Peerings and Private Links (Private Endpoints)
  enable_dns_hostnames = true
  enable_dns_support   = true

#TGW for spoke accounts Configuration
  create_accepter = true
  attachment_creation = true

#   ram_share_arn = data.terraform_remote_state.ram_producer.outputs.shares_ram_shared_arn #Uncomment for TGW acceptance - In case of multiple TGW PROVIDE ARN manually

#S3 VPC Endpoints - Gateway
  s3_gw_endpoints = true
}

################################################################################
# VPC Spoke - TGW Routing - Run Only when TGW Attachment is accepted and conf in HUB
################################################################################

# module "vpc1-route" {
#   source  = "./modules/tgw-routing"

# #Basic Info
#   tgw_id = module.vpc1.transit_gateway_id != null ? module.vpc1.transit_gateway_id : ""

# #Subnet Info
#   public-subnets = module.vpc1.public_subnet_ids
#   private-subnets = module.vpc1.private_subnet_ids
#   staging-subnets = module.vpc1.staging_subnet_ids

# #RT Info
#   public-rt  = module.vpc1.public_route_table_ids
#   private-rt = module.vpc1.private_route_table_id != null ? [module.vpc1.private_route_table_id] : []
#   staging-rt = module.vpc1.staging_route_table_id != null ? [module.vpc1.staging_route_table_id] : []

#   default_tgw_route   = true
#   default_staging_tgw = true

#   depends_on = [module.vpc1]

# }