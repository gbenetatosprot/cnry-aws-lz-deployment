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

  name            = "bene-vpc-1"
  cidr            = "10.160.10.0/23"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.160.10.0/25", "10.160.11.0/25"]
  public_subnets  = ["10.160.10.128/26", "10.160.11.128/26"]
  staging_subnets = ["10.160.10.192/27"]

  private_subnet_names = ["Private-AZ1", "Private-AZ2"]
  public_subnet_names = ["Public-AZ1", "Public-AZ2"]
#   staging_subnet_names = ["Staging-Subnet-AZ1-PRV"]

  enable_nat_gateway = true


  enable_dns_hostnames = true
  enable_dns_support   = true

  create_accepter = false
  attachment_creation = false

  create_igw = true
  public_default_route = true


#   ram_share_arn = data.terraform_remote_state.ram_producer.outputs.shares_ram_shared_arn

#   create_staging_subnet_route_table = true
}
