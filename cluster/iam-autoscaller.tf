data "aws_iam_policy_document" "eks_autoscaller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:clauster-autoscaler"]  # This is our created service account and we pass this because oidc
    }                                                   # manages the iam policy/role for the service acc [i.e will allow the service acc to use the policy its(oidc) assumed]

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_autoscaller" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "autoscaller-role"
}

resource "aws_iam_policy" "scalling_policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoscalingGroup",
        "autoscaling:DescribeAutoscalingInstances",
        "autoscaling:DescribeLaunchConfiguration",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoscalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeInstanceTypes"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "autoscaller_attach" {
  role       = aws_iam_role.eks_autoscaller.name
  policy_arn = aws_iam_policy.scalling_policy.arn
}

output "scalling_policy_arn" {
  value = aws_iam_role.eks-autoscaller.arn
}