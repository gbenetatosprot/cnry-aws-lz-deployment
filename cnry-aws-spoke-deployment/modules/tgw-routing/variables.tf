################################################################################
# VPC Related Variables
################################################################################

variable "public-subnets" {
  description = "Public Subnets IDs"
  type        = list(string)
  default     = []
}

variable "private-subnets" {
  description = "Private Subnets IDs"
  type        = list(string)
  default     = []
}

variable "staging-subnets" {
  description = "Private Subnets IDs"
  type        = list(string)
  default     = []
}

variable "public-rt" {
  description = "Public rt IDs"
  type        = list(string)
  default     = []
}

variable "private-rt" {
  description = "Private rt IDs"
  type        = list(string)
  default     = []
}

variable "staging-rt" {
  description = "Private rts IDs"
  type        = list(string)
  default     = []
}

variable "default_tgw_route" {
  description = "Adds default route to TGW to Private and Public"
  type        = bool
  default     = true
}

variable "default_staging_tgw" {
  description = "Adds default route to TGW to staging"
  type        = bool
  default     = true
}

variable "tgw_id" {
  type    = string
}