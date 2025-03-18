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