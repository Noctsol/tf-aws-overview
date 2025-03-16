/*
    Module made to peer VPCS and set up routing tables
*/
variable "requester_vpc_id" {}
variable "requester_route_table_id" {}
variable "requester_cidr_block" {}

variable "accepter_vpc_id" {}
variable "accepter_route_table_id" {}
variable "accepter_cidr_block" {}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [
        aws.requester,
        aws.accepter
      ]
    }
  }
}

# provider "aws" {
#   alias = requester
# }

# provider "aws" {
#   alias = accepter
# }

data "aws_caller_identity" "requester" {
  provider = aws.requester
}
data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

resource "aws_vpc_peering_connection" "this" {
  provider    = aws.requester
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_owner_id = data.aws_caller_identity.accepter.account_id
  auto_accept = false
  tags = {
    Name = "peer-${var.requester_vpc_id}-${var.accepter_vpc_id}"
    side = "requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true
  tags = {
    Name = "peer-${var.requester_vpc_id}-${var.accepter_vpc_id}"
    side = "accepter"
  }
}

resource "aws_route" "requester" {
  provider                  = aws.requester
  route_table_id            = var.requester_route_table_id
  destination_cidr_block    = var.accepter_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "accepter" {
  provider                  = aws.accepter
  route_table_id            = var.accepter_route_table_id
  destination_cidr_block    = var.requester_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

output "requester_peer_id" {
  value = aws_vpc_peering_connection.this.id
}
output "accepter_peer_id" {
  value = aws_vpc_peering_connection_accepter.this.id
}
