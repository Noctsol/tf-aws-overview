/*

Deploying VPCs everywhere
Ideally, should have 50k+ IPs in each VPC
# Some network addresses
10.0.0.0/17
10.0.128.0/17
10.1.0.0/17
10.1.128.0/17
*/

###### CREATING VPCS ######
# Virtual private cloud and their subnets
resource "aws_vpc" "rootwest" {
  cidr_block = "10.0.0.0/17"
  tags = {
    Name = "vpcrootwest"
    env  = "dev"
  }
}
resource "aws_subnet" "rootwest" {
  vpc_id     = aws_vpc.rootwest.id
  cidr_block = "10.0.0.0/22"
  tags = {
    Name = "subnetrootwestdefault"
    env  = "dev"
  }
}
resource "aws_route_table" "rootwest" {
  vpc_id = aws_vpc.rootwest.id
  tags = {
    Name = "routetablerootwest"
    env  = "dev"
  }
}


resource "aws_vpc" "acct1west2" {
  provider   = aws.acct1west2
  cidr_block = "10.0.128.0/17"
  tags = {
    Name = "vpcacct1west2"
    env  = "dev"
  }
}
resource "aws_subnet" "acct1west2" {
  provider   = aws.acct1west2
  vpc_id     = aws_vpc.acct1west2.id
  cidr_block = "10.0.128.0/22"
  tags = {
    Name = "subnetacct1west2default"
    env  = "dev"
  }
}
resource "aws_route_table" "acct1west2" {
  provider = aws.acct1west2
  vpc_id   = aws_vpc.acct1west2.id
  tags = {
    Name = "routetableacct1west2"
    env  = "dev"
  }
}

module "vpc_acct2west2" {
  source     = "./vpc"
  vpc_name   = "acct2west2"
  cidr_block = "10.1.0.0/17"
  tags = {
    Environment = "dev"
  }
  providers = {
    aws = aws.acct2west2
  }
}

resource "aws_subnet" "acct2west2" {
  provider   = aws.acct2west2
  vpc_id     = module.vpc_acct2west2.vpc_id
  cidr_block = "10.1.0.0/22"
  tags = {
    Name        = "subnetacct2west2default"
    Environment = "dev"
  }
}


###### PEERING VPCS ######
# # Peering connections between VPCs - I prefer using TGW but this is a good example
# # How to peer VPC's manually
# resource "aws_vpc_peering_connection" "rootwest-acct1west2" {
#   #provider    = aws.acct1west2
#   vpc_id        = aws_vpc.rootwest.id
#   peer_owner_id = aws_organizations_account.testaccount1.id
#   peer_vpc_id   = aws_vpc.acct1west2.id
#   auto_accept   = false # Must be false when doing cross-account peering
#   tags = {
#     Name = "peer-rootwest-acct1west2"
#     env  = "dev"
#     side = "requester"
#   }
# }

# # Yeah, you have to accept the peering connection, pretty tedious
# resource "aws_vpc_peering_connection_accepter" "rootwest-acct1west2" {
#   provider                  = aws.acct1west2
#   vpc_peering_connection_id = aws_vpc_peering_connection.rootwest-acct1west2.id
#   auto_accept               = true
#   tags = {
#     Name = "peer-rootwest-acct1west2"
#     env  = "dev"
#     side = "accepter"
#   }
# }
# # AND THEN YOU HAVE TO THE ROUTES MANUALLY
# resource "aws_route" "rootwest-acct1west2-requester" {
#   route_table_id            = aws_route_table.rootwest.id
#   destination_cidr_block    = aws_vpc.acct1west2.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.rootwest-acct1west2.id
# }
# resource "aws_route" "acct1west2-rootwest-accepter" {
#   provider                  = aws.acct1west2
#   route_table_id            = aws_route_table.acct1west2.id
#   destination_cidr_block    = aws_vpc.rootwest.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.rootwest-acct1west2.id
# }


# module "vpc_peer_root-to-acct2west2" {
#   source = "./vpc_peer"
#   requester_vpc_id = aws_vpc.rootwest.id
#   requester_route_table_id = aws_route_table.rootwest.id
#   requester_cidr_block = aws_vpc.rootwest.cidr_block
#   accepter_vpc_id = module.vpc_acct2west2.vpc_id
#   accepter_route_table_id = module.vpc_acct2west2.route_table_id
#   accepter_cidr_block = module.vpc_acct2west2.vpc_cidr_block
#   providers = {
#     aws.requester = aws
#     aws.accepter = aws.acct2west2
#   }
# }

# module "vpc_peer_acct1west2-to-acct2west2" {
#   source = "./vpc_peer"
#   requester_vpc_id = aws_vpc.acct1west2.id
#   requester_route_table_id = aws_route_table.acct1west2.id
#   requester_cidr_block = aws_vpc.acct1west2.cidr_block
#   accepter_vpc_id = module.vpc_acct2west2.vpc_id
#   accepter_route_table_id = module.vpc_acct2west2.route_table_id
#   accepter_cidr_block = module.vpc_acct2west2.vpc_cidr_block
#   providers = {
#     aws.requester = aws.acct1west2
#     aws.accepter = aws.acct2west2
#   }
# }



##### USING TRANSIT GATEWAY - SET UP 1 (ENABLED, ENABLED) #####
# 1. Create a transit gateway and route table
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "My Default Transit Gateway"
  amazon_side_asn                 = 64512 # Default ASN
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name        = "roottgw"
    Environment = "prod"
  }
}
resource "aws_ec2_transit_gateway_route_table" "rootwest" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name        = "tgwroutetablerootwest"
    Environment = "prod"
  }
}

# 2. Attach VPCs to TGW via attachments
#   - associate the route table with the attachment with association
#   -  Add routes to the VPC route tables to rout through the TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "rootwest" {
  subnet_ids         = [aws_subnet.rootwest.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.rootwest.id
}

# Cross account works a little differently, you need to expose the TGW to the other accounts
# Also need to expose the route table
resource "aws_ram_resource_share" "rootwest" {
  name                      = "rootwesttgwshare"
  allow_external_principals = false
  tags = {
    Name        = "tgwshare"
    Environment = "prod"
  }
}

# Associating the TGW with the resource share
resource "aws_ram_resource_association" "tgw_association" {
  resource_share_arn = aws_ram_resource_share.rootwest.arn
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
}

resource "aws_ram_principal_association" "acct1west2" {
  resource_share_arn = aws_ram_resource_share.rootwest.arn
  principal          = aws_organizations_account.testaccount1.id
}

resource "aws_ram_principal_association" "acct2west2" {
  resource_share_arn = aws_ram_resource_share.rootwest.arn
  principal          = aws_organizations_account.testaccount2.id
}

# Associate the route table with the resource share
resource "aws_ram_resource_share" "rootwesttgwroutetableshare" {
  name                      = "rootwesttgwroutetableshare"
  allow_external_principals = false
  tags = {
    Name        = "rootwesttgwroutetableshare"
    Environment = "prod"
  }
}
# resource "aws_ram_resource_association" "routetableshare" {
#   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
#   resource_arn       = aws_ec2_transit_gateway_route_table.rootwest.arn
# }

# resource "aws_ram_principal_association" "acct1west2routetable" {
#   provider           = aws.acct1west2
#   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
#   principal          = aws_organizations_account.testaccount1.id
# }
# resource "aws_ram_principal_association" "acct2west2routetable" {
#   provider           = aws.acct2west2
#   resource_share_arn = aws_ram_resource_share.rootwesttgwroutetableshare.arn
#   principal          = aws_organizations_account.testaccount2.id
# }


# Now you can attach the VPCs from other accounts as TGW will be shared
resource "aws_ec2_transit_gateway_vpc_attachment" "acct1west2" {
  provider           = aws.acct1west2
  subnet_ids         = [aws_subnet.acct1west2.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.acct1west2.id
  depends_on         = [aws_ram_principal_association.acct1west2]
}
# resource "aws_ec2_transit_gateway_route_table_association" "acct1west2" {
#   provider                       = aws.acct1west2
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct1west2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   depends_on                     = [aws_ram_principal_association.acct1west2routetable]
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "acct2west2" {
  provider           = aws.acct2west2
  subnet_ids         = [aws_subnet.acct2west2.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc_acct2west2.vpc_id
  depends_on         = [aws_ram_principal_association.acct2west2]
}
# resource "aws_ec2_transit_gateway_route_table_association" "acct2west2" {
#   provider                       = aws.acct2west2
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.acct2west2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rootwest.id
#   depends_on                     = [aws_ram_principal_association.acct2west2routetable]
# }

# 3. Set VPCs route tables to route through the TGW
resource "aws_route" "rootwest" {
  route_table_id            = aws_route_table.rootwest.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "acct1west2" {
  provider                  = aws.acct1west2
  route_table_id            = aws_route_table.acct1west2.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "acct2west2" {
  provider                  = aws.acct2west2
  route_table_id            = module.vpc_acct2west2.route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
}



# In order
# 1. Create TGW
# 2. Create TGW route table
# 3. Attach VPCs to TGW via attachments
#   - associate the route table with the attachment with association
#   -  Add routes to the VPC route tables
#4. Add routes to the tgw route table
# 5. Add routes to the VPC route tables


########## USING TRANSIT GATEWAY - SET UP (DISABLED, DISABLED) ##########
