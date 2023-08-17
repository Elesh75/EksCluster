data "terraform_remote_state" "vpc" {
  backend = "local" # This is where our vpc statefile is stored 

  config = {
    path = "../vpc/terraform.tfstate" # the statefile location on our local server
  }
}

# Create node group in the created VPC using the node-group role you created
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private_nodes"
  node_role_arn   = data.terraform_remote_state.vpc.outputs.node_role

  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private[0], data.terraform_remote_state.vpc.outputs.private[1]
  ]

  scaling_config {
    desired_size = 3
    max_size     = 8
    min_size     = 2
  }

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.micro"]

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # This tag is very important when using an auto-scaller
  tags = {
    "k8s.io/cluster-autoscaller/demo"    = "owned"
    "k8s.io/cluster-autoscaller/enabled" = true
  }

  depends_on = [
    aws_eks_cluster.demo
  ]
}