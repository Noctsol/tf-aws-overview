/*
Makes users at the root level and assigns them to the group
*/

resource "aws_iam_user" "admin" {
  name = "svc-admin"
  path = "/service-accounts/"
}
resource "aws_iam_user_group_membership" "admin" {
  user   = aws_iam_user.admin.name
  groups = [aws_iam_group.serviceaccounts.name]
}


resource "aws_iam_user" "somedeveloper" {
  name = "dev-user"
  path = "/users/"
}
resource "aws_iam_user_group_membership" "somedeveloper" {
  user   = aws_iam_user.somedeveloper.name
  groups = [aws_iam_group.developers.name]
}
resource "aws_iam_user_group_membership" "somedeveloperbobbyapp" {
  user   = aws_iam_user.somedeveloper.name
  groups = [aws_iam_group.bobbyapp.name]
}


resource "aws_iam_user" "terraformuser" {
  name = "svc-terraform"
  path = "/service-accounts/"
}
resource "aws_iam_user_group_membership" "terraformuser" {
  user   = aws_iam_user.terraformuser.name
  groups = [aws_iam_group.serviceaccounts.name]
}
