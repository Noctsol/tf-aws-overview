output "accounts" {
  value = {
    testaccount1 = aws_organizations_account.testaccount1.id
    testaccount2 = aws_organizations_account.testaccount2.id
  }

}

output "vpcs" {
  value = {
    rootwest        = aws_vpc.rootwest.id
    rootwest_cidr   = aws_vpc.rootwest.cidr_block
    acct1west2      = aws_vpc.acct1west2.id
    acct1west2_cidr = aws_vpc.acct1west2.cidr_block
    acct2west2      = module.vpc_acct2west2.vpc_id
    acct2west2_cidr = module.vpc_acct2west2.vpc_cidr_block

  }
}

# aws sts assume-role --role-arn "arn:aws:iam::872515282678:role/OrganizationAccountAccessRole" --role-session-name "test-session" --profile adminuser
#
