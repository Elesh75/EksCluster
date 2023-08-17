data "aws_iam_policy_document" "developer" {
  statement {
    sid = "AllowDeveloper"

    actions = [
      "eks:DescribeNodegroup",
      "eks:ListNodegroup",
      "eks:ListClusters",
      "eks:ListUpdates",
      "eks:ListFargateProfiles",
      "eks:AccessKubernetesApi",
      "ssm:GetParameter",
      "eks:DescribeCluster"
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}  

data "aws_iam_policy_document" "admin" {
  statement {
    sid = "AllowAdmin"
    effect = "Allow"
    action = ["*"]
    resources = ["*"]
  }
  statement {
    sid = "AllowPassRole"
    effect = "Allow"
    action = [
        "iam:PassRole"
    ]
    resources = ["*"]
    condition {
        test = "StringEquals"
        variable = "iam:PassedToService"
        value = ["eks.amazon.com"]
    }
  }
 }

 data "aws_iam_policy_document" "manager_assume_role" {
  statement {
    sid = "AllowManagerAssumeRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin-user"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_caller_identity" "current" {}

output "role_arn" {
  value = aws_iam_role.example_role.arn
}



