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
  # Authorization is on tf cloud with the environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

  # access_key = var.aws_access_id
  # secret_key = var.aws_secret_key
  # profile = "terraform-user"
}

# # Connect to account 1
provider "aws" {
  alias  = "acct1west2"
  region = "us-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.testaccount1.id}:role/OrganizationAccountAccessRole"
    session_name = "terraformwest2"
  }
}

# # Connect to account 2
provider "aws" {
  alias  = "acct2west2"
  region = "us-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.testaccount2.id}:role/OrganizationAccountAccessRole"
    session_name = "terraformwest2"
  }
}