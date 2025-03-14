resource "aws_iam_policy" "admins_policy" {
  name        = "admins"
  path        = "/roles/"  # not sure if its going here
  description = "Lets admins access other accounts"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:iam::${aws_organizations_account.testaccount1.id}:role/AdminRole",
          "arn:aws:iam::${aws_organizations_account.testaccount1.id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${aws_organizations_account.testaccount2.id}:role/AdminRole",
          "arn:aws:iam::${aws_organizations_account.testaccount2.id}:role/OrganizationAccountAccessRole"
        ]
      },
    ]
  })
}