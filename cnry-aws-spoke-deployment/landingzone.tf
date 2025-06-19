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
  attachment_creation = false
#   ram_share_arn = data.terraform_remote_state.ram_producer.outputs.shares_ram_shared_arn #Uncomment for TGW acceptance - In case of multiple TGW PROVIDE ARN manually
}
