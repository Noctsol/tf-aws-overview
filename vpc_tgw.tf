# https://dev.to/charlesuneze/configuring-a-transit-gateway-between-3-vpcs-using-terraform-4off

# ##### USING TRANSIT GATEWAY - SET UP 1 (ENABLED, ENABLED) #####
# # 0. Setting up a public subnet with a NAT Gateway
# # This is for the TGW to have internet access
# resource "aws_subnet" "rootwest_public" {
#   vpc_id                  = aws_vpc.rootwest.id
#   cidr_block              = "10.0.4.0/24" # Ensure this does not overlap with existing subnets
#   map_public_ip_on_launch = true
#   availability_zone       = "us-west-2b"
#   tags = {
#     Name = "rootwest-public-subnet"
#   }
# }
# resource "aws_internet_gateway" "rootwest_igw" {
#   vpc_id = aws_vpc.rootwest.id
#   tags   = { Name = "rootwest-IGW" }
# }
# resource "aws_eip" "rootwest_nat_eip" {
#   tags = {
#     Name = "rootwest-NATIP"
#   }
# }
# resource "aws_nat_gateway" "rootwest_nat" {
#   allocation_id = aws_eip.rootwest_nat_eip.id
#   subnet_id     = aws_subnet.rootwest_public.id
#   tags          = { Name = "rootwest-NAT" }
# }

# resource "aws_route_table" "rootwest_public_rt" {
#   vpc_id = aws_vpc.rootwest.id
#   tags   = { Name = "rootwest-public-route-table" }
# }

# resource "aws_route" "public_to_igw" {
#   route_table_id         = aws_route_table.rootwest_public_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.rootwest_igw.id
# }

# resource "aws_route_table_association" "rootwest_public_assoc" {
#   subnet_id      = aws_subnet.rootwest_public.id
#   route_table_id = aws_route_table.rootwest_public_rt.id
# }
# resource "aws_route" "rootwest_private_to_nat" {
#   route_table_id         = aws_route_table.rootwest.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.rootwest_nat.id
# }
# resource "aws_ec2_transit_gateway_route" "internet_via_rootwest" {
#   destination_cidr_block         = "0.0.0.0/0"
#   # transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rootwest.id
# }







# # 1. Create a transit gateway and route table
# # aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
# resource "aws_ec2_transit_gateway" "tgw" {
#   description                     = "My Default Transit Gateway"
#   amazon_side_asn                 = 64512 # Default ASN
#   auto_accept_shared_attachments  = "enable"
#   default_route_table_association = "enable"
#   default_route_table_propagation = "enable"
#   tags = {
#     Name        = "roottgw"
#     Environment = "prod"
#   }
# }
# # resource "aws_ec2_transit_gateway_route_table" "rootwest" {
# #   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
# #   tags = {
# #     Name        = "tgwroutetablerootwest"
# #     Environment = "prod"
# #   }
# # }

# # 2. Attach VPCs to TGW via attachments
# #   - associate the route table with the attachment with association
# #   -  Add routes to the VPC route tables to rout through the TGW
# resource "aws_ec2_transit_gateway_vpc_attachment" "rootwest" {
#   subnet_ids         = [aws_subnet.rootwest.id, aws_subnet.rootwest_public.id]
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = aws_vpc.rootwest.id
# }

# # Cross account works a little differently, you need to expose the TGW to the other accounts
# # Also need to expose the route table
# resource "aws_ram_resource_share" "rootwest" {
#   name                      = "rootwesttgwshare"
#   allow_external_principals = false
#   tags = {
#     Name        = "tgwshare"
#     Environment = "prod"
#   }
# }

# # Associating the TGW with the resource share
# resource "aws_ram_resource_association" "tgw_association" {
#   resource_share_arn = aws_ram_resource_share.rootwest.arn
#   resource_arn       = aws_ec2_transit_gateway.tgw.arn
# }

# resource "aws_ram_principal_association" "acct1west2" {
#   resource_share_arn = aws_ram_resource_share.rootwest.arn
#   principal          = aws_organizations_account.testaccount1.id
# }

# resource "aws_ram_principal_association" "acct2west2" {
#   resource_share_arn = aws_ram_resource_share.rootwest.arn
#   principal          = aws_organizations_account.testaccount2.id
# }

# # # Associate the route table with the resource share
# # resource "aws_ram_resource_share" "rootwesttgwroutetableshare" {
# #   name                      = "rootwesttgwroutetableshare"
# #   allow_external_principals = false
# #   tags = {
# #     Name        = "rootwesttgwroutetableshare"
# #     Environment = "prod"
# #   }
# # }
# # resource "aws_ram_resource_association" "routetableshare" {
# #   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
# #   resource_arn       = aws_ec2_transit_gateway_route_table.rootwest.arn
# # }

# # resource "aws_ram_principal_association" "acct1west2routetable" {
# #   #provider           = aws.acct1west2
# #   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
# #   principal          = aws_organizations_account.testaccount1.id
# # }
# # resource "aws_ram_principal_association" "acct2west2routetable" {
# #   #provider           = aws.acct2west2
# #   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
# #   principal          = aws_organizations_account.testaccount2.id
# # }


# # Now you can attach the VPCs from other accounts as TGW will be shared
# resource "aws_ec2_transit_gateway_vpc_attachment" "acct1west2" {
#   provider           = aws.acct1west2
#   subnet_ids         = [aws_subnet.acct1west2.id]
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = aws_vpc.acct1west2.id
#   depends_on         = [aws_ram_principal_association.acct1west2]
# }
# # resource "aws_ec2_transit_gateway_route_table_association" "acct1west2" {
# #   provider                       = aws.acct1west2
# #   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct1west2.id
# #   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
# #   depends_on                     = [aws_ram_principal_association.acct1west2routetable]
# # }

# resource "aws_ec2_transit_gateway_vpc_attachment" "acct2west2" {
#   provider           = aws.acct2west2
#   subnet_ids         = [aws_subnet.acct2west2.id]
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = module.vpc_acct2west2.vpc_id
#   depends_on         = [aws_ram_principal_association.acct2west2]
# }
# # resource "aws_ec2_transit_gateway_route_table_association" "acct2west2" {
# #   provider                       = aws.acct2west2
# #   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct2west2.id
# #   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
# #   depends_on                     = [aws_ram_principal_association.acct2west2routetable]
# # }

# # 3. Set VPCs route tables to route through the TGW
# resource "aws_route" "rootwestclassA" {
#   route_table_id         = aws_route_table.rootwest.id
#   destination_cidr_block = local.classA_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "rootwestclassB" {
#   route_table_id         = aws_route_table.rootwest.id
#   destination_cidr_block = local.classB_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "rootwestclassC" {
#   route_table_id         = aws_route_table.rootwest.id
#   destination_cidr_block = local.classC_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }



# resource "aws_route" "acct1west2classA" {
#   provider               = aws.acct1west2
#   route_table_id         = aws_route_table.acct1west2.id
#   destination_cidr_block = local.classA_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct1west2classB" {
#   provider               = aws.acct1west2
#   route_table_id         = aws_route_table.acct1west2.id
#   destination_cidr_block = local.classB_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct1west2classC" {
#   provider               = aws.acct1west2
#   route_table_id         = aws_route_table.acct1west2.id
#   destination_cidr_block = local.classC_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct1west2_to_tgw_public" {
#   provider               = aws.acct1west2
#   route_table_id         = aws_route_table.acct1west2.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }




# resource "aws_route" "acct2west2classA" {
#   provider               = aws.acct2west2
#   route_table_id         = module.vpc_acct2west2.route_table_id
#   destination_cidr_block = local.classA_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct2west2classB" {
#   provider               = aws.acct2west2
#   route_table_id         = module.vpc_acct2west2.route_table_id
#   destination_cidr_block = local.classB_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct2west2classC" {
#   provider               = aws.acct2west2
#   route_table_id         = module.vpc_acct2west2.route_table_id
#   destination_cidr_block = local.classC_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }
# resource "aws_route" "acct2west2_to_tgw_public" {
#   provider               = aws.acct2west2
#   route_table_id         = module.vpc_acct2west2.route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }



# resource "aws_ec2_transit_gateway_route" "rootwest_to_tgw" {
#   destination_cidr_block         = aws_vpc.rootwest.cidr_block
#   # transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.rootwest.id
#   provider                       = aws  # Root account
# }

# resource "aws_ec2_transit_gateway_route" "acct1west2_to_tgw" {
#   destination_cidr_block         = aws_vpc.acct1west2.cidr_block
#   # transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct1west2.id
#   # provider                       = aws.acct1west2  # Account 1 West 2
# }

# resource "aws_ec2_transit_gateway_route" "acct2west2_to_tgw" {
#   destination_cidr_block         = module.vpc_acct2west2.vpc_cidr_block
#   # transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct2west2.id
#   # provider                       = aws.acct2west2  # Account 2 West 2
# }







# # In order
# # 1. Create TGW
# # 2. Create TGW route table
# # 3. Attach VPCs to TGW via attachments
# #   - associate the route table with the attachment with association
# #   -  Add routes to the VPC route tables
# #4. Add routes to the tgw route table
# # 5. Add routes to the VPC route tables


# ########## USING TRANSIT GATEWAY - SET UP (DISABLED, DISABLED) ##########
