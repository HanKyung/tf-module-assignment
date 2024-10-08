

data "aws_iam_role" "AWSServiceRoleForAmazonEKS" {
    name = "AWSServiceRoleForAmazonEKS"
}

resource "aws_eks_cluster" "CE7-Stephen" {
  name     = "CE7-Stephen"
  role_arn = data.aws_iam_role.AWSServiceRoleForAmazonEKS.arn

  vpc_config {
    subnet_ids = aws_subnet.public_subnets[*].id
  }
}

resource "aws_eks_node_group" "Stephen-CE7-node-group" {
  cluster_name    = aws_eks_cluster.CE7-Stephen.name
  node_group_name = "Stephen-CE7-node-group"
  node_role_arn   = data.aws_iam_role.AWSServiceRoleForAmazonEKS.arn
  subnet_ids      = aws_subnet.public_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

#   remote_access {
#     ec2_ssh_key = "my-key"
#   }

  tags = {
    Name = "CE7-stephen-node-group"
  }
}




data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = aws_eks_cluster.CE7-Stephen.name
}

provider "kubernetes" {
  alias = "eks"
  host                   = aws_eks_cluster.CE7-Stephen.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.CE7-Stephen.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"

  providers = {
    kubernetes = "kubernetes.eks"
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.aws_region
  k8s_cluster_name = aws_eks_cluster.CE7-Stephen.name
}