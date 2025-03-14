/*
    This file generates new aws accounts.
    Due to how this works. You need to run this file first before the other providers can be created
    in provider.tf
*/

resource "aws_organizations_account" "testaccount1" {
  name  = "testaccount1"
  email = var.test_email_1
}

resource "aws_organizations_account" "testaccount2" {
  name  = "testaccount2"
  email = var.test_email_2
}