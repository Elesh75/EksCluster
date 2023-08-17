resource "aws_iam_user_login_profile" "DD_user" {
  count                   = length(var.iam_usernames)
  user                    = aws_iam_user.eks_user.name
  password_reset_required = true
  pgp_key                 = "keybase:DEMO1.pem "
}

resource "aws_iam_user" "eks_user" {
    count = length(var.iam_usernames)
    name = elemant(var.iam_usernames, count.index)
    force_destroy = true

    tags = {
      Department = "eks-user"
    }
}

resource "aws_iam_group" "eks_developers" {
    name = "Developer"
}

resource "aws_iam_group_policy" "my_developer_policy" {
  name  = "my_developer_policy"
  group = aws_iam_group.eks_developers.name
  policy = data.aws_iam_policy_document.developer.json
}

# Allocate members to the group
resource "aws_iam_group_membership" "team" {
  name = "dev-group-membership"
  users = [aws_iam_user.eks_user[0].name]
  group = aws_iam_group.eks_developers.name
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_role" "managers_role" {
  name = "manager_role"
  assume_role_policy = data.aws_iam_policy_document.manager_assume_role.json
}

resource "aws_iam_role_policy" "eks_admin" {
  name = "eks-admin"
  policy_arn = data.aws_iam_policy_document.admin.json
}

resource "aws_iam_role_policy_attachment" "adminroleattachment" {
  role       = aws_iam_role.managers_role
  policy_arn = data.aws_iam_policy.eks_admin.arn
}
 