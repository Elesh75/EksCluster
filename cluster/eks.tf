resource "aws_eks_cluster" "demo" {
  name     = "demo"
  role_arn = data.terraform_remote_state.vpc.outputs.eks

  vpc_config {
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.private[0], data.terraform_remote_state.vpc.outputs.private[1],
      data.terraform_remote_state.vpc.outputs.public[0], data.terraform_remote_state.vpc.outputs.public[1]
    ]
  }
}