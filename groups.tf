/*
    Makes groups
*/


resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/groups/"
}

resource "aws_iam_group" "bobbyapp" {
  name = "bobbyapp-developers"
  path = "/teams/"
}

# Create admins groups and let users in it assume AdminRole
resource "aws_iam_group" "serviceaccounts" {
  name = "admins"
  path = "/groups/"
}
resource "aws_iam_group_policy_attachment" "admins_admin_access" {
  group      = aws_iam_group.serviceaccounts.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}