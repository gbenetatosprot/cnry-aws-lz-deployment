#----------------------------------------------------------------------------------------------------------------------
# Shared Variables
#----------------------------------------------------------------------------------------------------------------------

variable "ram_principals" {
  type    = list(string)
  default = ["123456789012", "987654321098"]
}

#----------------------------------------------------------------------------------------------------------------------
# Access Variables
#----------------------------------------------------------------------------------------------------------------------

variable "aws_access_key_id" {
  description = "(Required) IAM user Access Key"
  type        = string
}

variable "aws_secret_access_key" {
  description = "(Required) IAM user Secret Access Key"
  type        = string
  sensitive   = true
}

#----------------------------------------------------------------------------------------------------------------------
# CIDR Variables
#----------------------------------------------------------------------------------------------------------------------

variable "hub_address" {
  description = "(Required) HUB VPC cidr"
  type        = list
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series Variables
#----------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  description = "(Required) Instance Size"
  type        = string
}

#----------------------------------------------------------------------------------------------------------------------
#General Variables
#----------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "(Required) AWS region for deployment"
  type        = string
}

variable "aws_availability_zone" {
  description = "(Required) AWS Availability Zone for deployment - Single AZ"
  type        = string
}

variable "protera_coid" {
  description = "(Required) COID"
  type        = string
}

variable "protera_env" {
  description = "(Required) Environment (PROD, QAS, SBX, DEV)"
  type        = string
}

variable "protera_location" {
  description = "(Required) Region"
  type        = string
}

variable "protera_location_short" {
  description = "(Required) Region initial (eg e: east, w: west)"
  type        = string
}