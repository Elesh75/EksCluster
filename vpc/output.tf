output "private" {
  value = aws_subnet.private.*.id
}

output "public" {
  value = aws_subnet.public.*.id
}

output "node_role" {
  value = aws_iam_role.node.arn
}

output "eks" {
  value = aws_iam_role.eks.arn
}