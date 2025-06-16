#----------------------------------------------------------------------------------------------------------------------
#General Variables
#----------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
    description = "(Required) AWS region"
	type = string
}

variable "aws_availability_zone" {
    description = "(Required) AWS Availability Zone"
	type = string
}

variable "il_external" {
    description = "(Required) oakbrook IP for IPsec"
    type = string
	default = "207.223.34.132"
}

variable "coid" {
    description = "(Required) COID"
    type = string
}

variable "location_short" {
    description = "(Required) Location Short"
    type = string
}

variable "environment" {
    description = "(Required) Environment"
    type = string
}


#----------------------------------------------------------------------------------------------------------------------
#CIDR Variables
#----------------------------------------------------------------------------------------------------------------------

variable "hub_address_space" {
    description = "(Required) Firewall VPC Range"
	type = list(string)
}

variable "public_space_prefix" {
    description = "(Required) Public Subnet Range"
	type = list(string)
}

variable "private_space_prefix" {
    description = "(Required) Private Subnet Range"
	type = list(string)
}

variable "mgmt_space_prefix" {
    description = "(Required) ΜΓΜΤ Subnet Range"
	type = list(string)
}

variable "tgw_space_prefix" {
    description = "(Required) TGW Subnet Range"
	type = list(string)
}

variable "ha2_space_prefix" {
    description = "(Required) HA Subnet Range"
	type = list(string)
}


#----------------------------------------------------------------------------------------------------------------------
#VM-Series Variables
#----------------------------------------------------------------------------------------------------------------------

#m5.xlarge for VM-100 and VM-300
#m5.2xlarge for VM-500
variable "instance_type" {
    description = "(Required) Instance size"
    type = string

}


#----------------------------------------------------------------------------------------------------------------------
#Security Groups Variables
#----------------------------------------------------------------------------------------------------------------------

variable "rules_inbound_public_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_outbound_public_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_inbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15"]
    }
    ]
}

variable "rules_outbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_inbound_mgmt_sg" {
  default = [
  
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15","52.147.201.44/32","207.223.34.132/32"]
    }
    ]
}

variable "rules_outbound_mgmt_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["100.70.0.20/32"]
    },

    {
      port = 49
      proto = "tcp"
      cidr_block = ["100.70.1.6/32","100.71.78.4/32"]
    },

    {
      port = 13004
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },

    {
      port = 25
      proto = "tcp"
      cidr_block = ["10.159.94.203/32"]
    },

    {
      port = 53
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },

    {
      port = 53
      proto = "udp"
      cidr_block = ["0.0.0.0/0"]
    }

    ]
}