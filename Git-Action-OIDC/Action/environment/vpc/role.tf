#Node group role
/*resource "aws_iam_role" "node" {
  name               = "eks-node-groups-role"
  assume_role_policy = data.aws_iam_policy_document.nodes.json # this block will creates an IAM role named "node"
}                                                              # with an associated IAM policy document that defines the trust relationship, 
# allowing other AWS resources (e.g nodes) or users to assume this IAM role.

resource "aws_iam_role_policy_attachment" "Nodepolicyattachment" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "Nodepolicyattachmen" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
# this block 9 - 30 specified the policy we are attaching to our node group role

resource "aws_iam_role_policy_attachment" "Nodepolicyattachmen" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_role_policy_attachment" "Nodepolicyattachment" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


# Eks cluster role
resource "aws_iam_role" "eks" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster.json
}

resource "aws_iam_role_policy_attachment" "eksclusterpolicyattachment" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
} # this block 39 - 47 specified the policy we are attaching to our node group role

resource "aws_iam_role_policy_attachment" "eksclusterpolicyattachment" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicyy"
}*/

#  OR for 9 - 30 and 39 - 47 this is a better way of writing the code so as to avoid bulkiness
locals {
  eks_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]

  node_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ]
}

#Node group role
resource "aws_iam_role" "node" {
  name               = "eks-node-groups-role"
  assume_role_policy = data.aws_iam_policy_document.nodes.json
}


resource "aws_iam_role_policy_attachment" "Nodepolicyattachment" {
  for_each   = toset(local.node_policies)
  role       = aws_iam_role.node.name # Here we use loop function
  policy_arn = each.value
}


resource "aws_iam_role" "eks" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster.json
}

resource "aws_iam_role_policy_attachment" "eksclusterpolicyattachment" {
  for_each   = toset(local.eks_policies)
  role       = aws_iam_role.eks.name # Here we use loop function
  policy_arn = each.value
} 