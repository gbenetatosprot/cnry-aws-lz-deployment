#----------------------------------------------------------------------------------------------------------------------
# Main Outputs
#----------------------------------------------------------------------------------------------------------------------

output "transit_gateway_id" {
  description = "TGW created in the Palo Alto module"
  value       = module.palo-alto.transit_gateway_id
}

output "transit_gateway_shared_arn" {
  description = "TGW shared ARN"
  value       = module.palo-alto.transit_gateway_id
}

output "shares_ram_shared_arn" {
  description = "RAM shared ARN"
  value       = aws_ram_resource_share.tgw_share.arn
}

#----------------------------------------------------------------------------------------------------------------------
# Main Outputs - VM-Series
#----------------------------------------------------------------------------------------------------------------------

output "vm_info_header" {
  value = <<EOT
============================================================
                    🔥 Palo Alto VM Firewalls
============================================================
EOT
}

output "vm_info_summary" {
  value = <<EOT
Firewall A:
  - Name: ${module.palo-alto.ec2-1-name}
  - Private IP: ${module.palo-alto.ec2-1-mgmt-ip-priv}
  - Public IP : ${module.palo-alto.ec2-1-mgmt-ip-pub}

Firewall B:
  - Name: ${module.palo-alto.ec2-2-name}
  - Private IP: ${module.palo-alto.ec2-2-mgmt-ip-priv}
  - Public IP : ${module.palo-alto.ec2-2-mgmt-ip-pub}
EOT
}