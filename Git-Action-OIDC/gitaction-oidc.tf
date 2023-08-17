data "tls_certificate" "eks" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "git_action" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts:amazonaws.com"
  ]

  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

#####################################################################################
# IAM Policy for OIDC provider

data "aws_iam_policy_document" "git_action_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.git_action.url, "https://", "")}:aud"
      values   = ["sts:amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.git_action.url, "https://", "")}:sub"
      values   = ["repo:Landmarktech21/EksCluster:*"] # This is our created repo
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.git_action.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "git_action_role" {
  assume_role_policy = data.aws_iam_policy_document.git_action_oidc_assume_role_policy.json
  name               = "Git-Role"
}

resource "aws_iam_policy" "git_action_policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "*"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "git_attach" {
  role       = aws_iam_role.git_action_role.name
  policy_arn = aws_iam_policy.git_action_policy.arn
}

output "git_action_role_arn" {
  value = aws_iam_role.git_action_role.arn
}
