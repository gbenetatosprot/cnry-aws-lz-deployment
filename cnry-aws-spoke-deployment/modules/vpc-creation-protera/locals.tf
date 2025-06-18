locals {
  len_public_subnets      = max(length(var.public_subnets))
  len_private_subnets     = max(length(var.private_subnets))
  len_staging_subnets    = max(length(var.staging_subnets))

  max_subnet_length = max(
    local.len_private_subnets,
    local.len_public_subnets,
    local.len_staging_subnets

  )

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = var.create_vpc

}