terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

variable "vpc_name" {}
variable "cidr_block" {}

variable enable_dns_support {
    default = true
    type = bool
}
variable enable_dns_hostnames {
    default = true
    type = bool
}
variable "tags" {
  type = map(string)
}

locals {
  vpc_tags = merge(var.tags, { Name = var.vpc_name })
  rt_tags = merge(var.tags, { Name = "${var.vpc_name}-routetable" })
}

# provider "aws" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = local.vpc_tags
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = local.rt_tags
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "route_table_id" {
  value = aws_route_table.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}