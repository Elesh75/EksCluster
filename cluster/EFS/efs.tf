module "eks-efs-csi-driver" {
  source  = "DNXLabs/eks-efs-csi-driver/aws"
  version = "0.1.5"

  cluster_identity_oidc_issuer = aws_eks_cluster.demo.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = aws_eks_cluster.demo.identity[0].oidc[0].issuer.url

  depends_on = [aws_eks_cluster.demo]
}

locals {
    vpc_id = data.teraform_remote_state.network.outputs.vpc_id
    vpc_cidr = data.teraform_remote_state.network.outputs.vpc_cidr

}

resource "aws_vpc_security_group" "allow_nfs" {
  name = "allow nfs"
  description = "Allow NFS inbound traffic"
  vpc_id = local.vpc_id

  cidr_blocks   = [local.vpc_cidr]
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049
}