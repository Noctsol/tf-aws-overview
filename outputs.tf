output "accounts" {
  value = {
    testaccount1 = aws_organizations_account.testaccount1.id
    testaccount2 = aws_organizations_account.testaccount2.id
  }

}

# aws sts assume-role --role-arn "arn:aws:iam::872515282678:role/OrganizationAccountAccessRole" --role-session-name "test-session" --profile adminuser
#