variable "aws_access_key_id" {
  type        = string
  default = ""
}

variable "aws_secret_access_key" {
  type        = string
  default = ""
}

variable "region" {
  description = "Region that the resources will be deployed"
  type = string
  default = ""
}

variable "coid" {
  description = "COID for the customer"
  type = string
  default = ""
}

variable "protera_env" {
  description = "Protera environment - prd/dev/qas/sbx"
  type = string
  default = ""
}

variable "protera_desc" {
  description = "Protera dec - tag"
  type = string
  default = ""
}

variable "protera_status" {
  description = "Protera status"
  type = string
  default = ""
}

variable "region_short" {
  description = "Region Short identifier - East(e)/West(w)"
  type = string
  default = ""
}

variable "protera_type" {
  description = "For naming - eg SAP, Shared etc"
  type = string
  default = ""
}