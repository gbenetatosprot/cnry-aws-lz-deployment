# ################################################################################
# # Routing for VPC - Run AFTER Attachment is accepted from hub
# ################################################################################

# #Get RT ID

# data "aws_route_table" "public_rt_data" {
#   filter {
#     name   = "tag:Name"
#     values = ["bene-vpc-1-public"]
# #   }
# }

# data "aws_route_table" "private_rt_data" {
#   filter {
#     name   = "tag:Name"
#     values = ["Private-Subnet-Rt"]
#   }
# }

# data "aws_route_table" "stage_rt_data" {
#   filter {
#     name   = "tag:Name"
#     values = ["bene-vpc-1-staging"]
#   }
# }

# data "aws_ec2_transit_gateway" "shared2" {
#   filter {
#     name   = "state"
#     values = ["available"]
#   }
# }

# #Set routes

# resource "aws_route" "pubrr" {
#   route_table_id            = data.aws_route_table.public_rt_data.id
#   destination_cidr_block    = "0.0.0.0/0"
#   transit_gateway_id        = data.aws_ec2_transit_gateway.shared2.id

# }

# resource "aws_route" "pivrr" {
#   route_table_id            = data.aws_route_table.private_rt_data.id
#   destination_cidr_block    = "0.0.0.0/0"
#   transit_gateway_id        = data.aws_ec2_transit_gateway.shared2.id

# }

# resource "aws_route" "stgrr" {
#   route_table_id            = data.aws_route_table.stage_rt_data.id
#   destination_cidr_block    = "0.0.0.0/0"
#   transit_gateway_id        = data.aws_ec2_transit_gateway.shared2.id

# }