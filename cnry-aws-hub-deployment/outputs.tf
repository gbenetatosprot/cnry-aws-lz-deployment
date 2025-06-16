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
  - Name: ${module.palo_alto.ec2-1-name}
  - Private IP: ${module.palo_alto.ec2-1-mgmt-ip-priv}
  - Public IP : ${module.palo_alto.ec2-1-mgmt-ip-pub}

Firewall B:
  - Name: ${module.palo_alto.ec2-2-name}
  - Private IP: ${module.palo_alto.ec2-2-mgmt-ip-priv}
  - Public IP : ${module.palo_alto.ec2-2-mgmt-ip-pub}
EOT
}