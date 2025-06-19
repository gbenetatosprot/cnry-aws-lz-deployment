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
  name            = "bene-vpc-1"
  cidr            = "10.160.10.0/23"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.160.10.0/25", "10.160.11.0/25"]
  public_subnets  = ["10.160.10.128/26", "10.160.11.128/26"]

  private_subnet_names = ["Private-AZ1", "Private-AZ2"]
  public_subnet_names = ["Public-AZ1", "Public-AZ2"]


#Staging Subnet Configuration
  staging_subnets = ["10.160.10.192/27"]
  staging_subnet_names = ["Staging-Subnet-AZ1-PRV"]
  create_staging_subnet_route_table = true
  create_staging_nat_gateway_route = false
  default_route_staging = true
  create_staging_internet_gateway_route = true

#NAT GW Configuration
  enable_nat_gateway = false
  single_nat_gateway = false

#IGW COnfiguration
  create_igw = false
  public_default_route = false

#VPC DNS Configuration - Important for Peerings and Private Links (Private Endpoints)
  enable_dns_hostnames = true
  enable_dns_support   = true

#TGW for spoke accounts Configuration
  create_accepter = false
  attachment_creation = true
  ram_share_arn = "arn:aws:ram:us-east-1:706210432878:resource-share/516c3c75-6dbe-4092-a2fd-3acfb1197244" #Uncomment for TGW acceptance - In case of multiple TGW PROVIDE ARN manually

#   ram_share_arn = data.terraform_remote_state.ram_producer.outputs.shares_ram_shared_arn #Uncomment for TGW acceptance - In case of multiple TGW PROVIDE ARN manually

#S3 VPC Endpoints - Gateway
  s3_gw_endpoints = true
}

module "vpc2" {
  source  = "./modules/vpc-creation-protera"

#Basic info
  region          = var.region
  name            = "bene-vpc-1"
  cidr            = "10.161.10.0/23"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.161.10.0/25", "10.161.11.0/25"]
  public_subnets  = ["10.161.10.128/26", "10.161.11.128/26"]

  private_subnet_names = ["Private-AZ1-1", "Private-AZ2-1"]
  public_subnet_names = ["Public-AZ1-1", "Public-AZ2-1"]


#Staging Subnet Configuration
  staging_subnets = ["10.161.10.192/27"]
  staging_subnet_names = ["Staging-Subnet-AZ1-PRV-1"]
  create_staging_subnet_route_table = true
  create_staging_nat_gateway_route = false
  default_route_staging = true
  create_staging_internet_gateway_route = true

#NAT GW Configuration
  enable_nat_gateway = false
  single_nat_gateway = false

#IGW COnfiguration
  create_igw = false
  public_default_route = false

#VPC DNS Configuration - Important for Peerings and Private Links (Private Endpoints)
  enable_dns_hostnames = true
  enable_dns_support   = true

#TGW for spoke accounts Configuration
  create_accepter = false
  attachment_creation = true
  ram_share_arn = "arn:aws:ram:us-east-1:706210432878:resource-share/516c3c75-6dbe-4092-a2fd-3acfb1197244" #Uncomment for TGW acceptance - In case of multiple TGW PROVIDE ARN manually

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
#   tgw_id = module.vpc1.transit_gateway_id

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

# module "vpc2-route" {
#   source  = "./modules/tgw-routing"

# #Basic Info
#   tgw_id = module.vpc2.transit_gateway_id

# #Subnet Info
#   public-subnets = module.vpc2.public_subnet_ids
#   private-subnets = module.vpc2.private_subnet_ids
#   staging-subnets = module.vpc2.staging_subnet_ids

# #RT Info
#   public-rt  = module.vpc2.public_route_table_ids
#   private-rt = module.vpc2.private_route_table_id != null ? [module.vpc2.private_route_table_id] : []
#   staging-rt = module.vpc2.staging_route_table_id != null ? [module.vpc2.staging_route_table_id] : []

#   default_tgw_route   = true
#   default_staging_tgw = true

#   depends_on = [module.vpc2]

# }