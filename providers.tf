terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.90.1"
        }
    }
}

provider "aws" {
    # profile = "terraform-user"
    region = "us-west-2"
    access_key = var.aws_access_id
    secret_key = var.aws_secret_key
}