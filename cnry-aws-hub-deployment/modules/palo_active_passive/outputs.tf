#----------------------------------------------------------------------------------------------------------------------
# Outputs of Palo Alto module
#----------------------------------------------------------------------------------------------------------------------

output "transit_gateway_id" {
  description = "Transit Gateway ID created by Palo Alto module"
  value       = aws_ec2_transit_gateway.main_tgw.id
}

output "tgw_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main_tgw.arn
}

output "ec2-1-id" {
  description = "ID of Firewall A"
  value       = aws_instance.vm1.id
}

output "ec2-2-id" {
  description = "ID of Firewall B"
  value       = aws_instance.vm2.id
}

output "ec2-1-mgmt-ip-priv" {
  description = "Private IP of Firewall A"
  value       = cidrhost(var.hub_address_space[0], 4)
}

output "ec2-2-mgmt-ip-priv" {
  description = "Private IP of Firewall B"
  value       = cidrhost(var.hub_address_space[0], 5)
}

output "ec2-1-mgmt-ip-pub" {
  description = "Public IP of Firewall A"
  value       = aws_eip.mng1.public_ip
}

output "ec2-2-mgmt-ip-pub" {
  description = "Public IP of Firewall B"
  value       = aws_eip.mng2.public_ip
}

output "ec2-1-name" {
  description = "Name of Firewall A"
  value       = join("", [var.coid, "-AWS", var.location_short, "pa00-a"])
}

output "ec2-2-name" {
  description = "Name of Firewall B"
  value       = join("", [var.coid, "-AWS", var.location_short, "pa00-b"])
}