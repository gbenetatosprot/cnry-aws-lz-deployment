variable "aws_access_key_id" {
  type        = string
  default = ""
}

variable "aws_secret_access_key" {
  type        = string
  default = ""
}

variable "ram_share_arn" {
  type = string
}

variable "region" {
  type = string
}

variable "create_accepter" {
  type = bool
}

variable "attachment_creation" {
  type = bool
}