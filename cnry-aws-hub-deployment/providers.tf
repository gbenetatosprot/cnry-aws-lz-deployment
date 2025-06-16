#----------------------------------------------------------------------------------------------------------------------
# Provider Block
#----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region                        = var.aws_region
  access_key                    = var.aws_access_key_id
  secret_key                    = var.aws_secret_access_key
}


#----------------------------------------------------------------------------------------------------------------------
# Terraform Block - TF Cloud
#----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "gbenetatos_Org"

    workspaces {
      name = "prot-cnry-aws-hub-deployment"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}