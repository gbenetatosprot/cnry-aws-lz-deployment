output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.create_vpc ? aws_vpc.this[0].id : null
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = local.create_public_subnets ? aws_subnet.public[*].id : []
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = local.create_private_subnets ? aws_subnet.private[*].id : []
}

output "staging_subnet_ids" {
  description = "List of staging subnet IDs"
  value       = local.create_staging_subnets ? aws_subnet.staging[*].id : []
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = local.create_public_subnets ? aws_route_table.public[*].id : []
}

output "private_route_table_id" {
  description = "Single private route table ID"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

output "staging_route_table_id" {
  description = "Staging route table ID"
  value       = local.create_staging_route_table ? aws_route_table.staging[0].id : null
}

output "public_network_acl_id" {
  description = "Public network ACL ID"
  value       = (local.create_public_subnets && var.public_dedicated_network_acl) ? aws_network_acl.public[0].id : null
}

output "private_network_acl_id" {
  description = "Private network ACL ID"
  value       = (local.create_private_network_acl) ? aws_network_acl.private[0].id : null
}

output "staging_network_acl_id" {
  description = "Staging network ACL ID"
  value       = (local.create_staging_network_acl) ? aws_network_acl.staging[0].id : null
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = (local.create_vpc && var.enable_nat_gateway) ? aws_nat_gateway.this[*].id : []
}

output "eip_allocation_ids" {
  description = "List of NAT EIP allocation IDs"
  value       = (local.create_vpc && var.enable_nat_gateway && !var.reuse_nat_ips) ? aws_eip.nat[*].id : []
}