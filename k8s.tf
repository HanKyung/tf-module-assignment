# data "aws_subnets" "public_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.app.id]
#   }
# }





################################################################################
# EKS Cluster Module
################################################################################

resource "aws_security_group" "stephn_eks_nodes_sg" {
  name        = "stephen-eks-nodes-sg"
  description = "EKS nodes security group"
  vpc_id      = module.stephen-assessment-vpc.vpc_id

  # ingress {
  #   from_port   = 3306
  #   to_port     = 3306
  #   protocol    = "tcp"
  #   # cidr_blocks = [module.stephen-assessment-vpc.vpc_cidr_block] # Adjust based on your setup
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "stephen-tf-cluster"
  cluster_version = "1.31"


  providers = {
    aws = aws.us-east-1
  }

  cluster_endpoint_public_access = true

  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.stephen-assessment-vpc.vpc_id         # data.aws_vpc.app.id
  subnet_ids               = module.stephen-assessment-vpc.public_subnets # aws_subnet.public_subnets[*].id
  control_plane_subnet_ids = module.stephen-assessment-vpc.public_subnets # aws_subnet.public_subnets[*].id

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    blue = {
      min_size     = 2
      max_size     = 10
      desired_size = 2

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
    }
    green = {
      min_size     = 2
      max_size     = 10
      desired_size = 2

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
    }
  }

  # customized config for eks cluster egress in db file
  node_security_group_id = aws_security_group.stephn_eks_nodes_sg.id


  tags = {
    env       = "dev"
    terraform = "true"
  }
}
################################################################################
# AWS ALB Controller
################################################################################

# module "alb_ingress_controller" {
#   source  = "iplabs/alb-ingress-controller/kubernetes"
#   version = "3.4.0"

#   providers = {
#     kubernetes = "kubernetes.eks"
#   }

#   k8s_cluster_type = "eks"
#   k8s_namespace    = "kube-system"

#   aws_region_name  = var.aws_region
#   k8s_cluster_name = data.aws_eks_cluster.target.name
# }

# module "lb_role" {
# source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

# role_name                              = "${var.env_name}_eks_lb"
# attach_load_balancer_controller_policy = true

# oidc_providers = {
#     main = {
#     provider_arn               = module.eks.oidc_provider_arn
#     namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
# }
# }


# resource "kubernetes_service_account" "service-account" {
# metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#     "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#     "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#     "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#     "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
# }
# }




# resource "helm_release" "alb-controller" {
# name       = "aws-load-balancer-controller"
# repository = "https://aws.github.io/eks-charts"
# chart      = "aws-load-balancer-controller"
# namespace  = "kube-system"
# depends_on = [
#     kubernetes_service_account.service-account
# ]

# set {
#     name  = "region"
#     value = var.aws_region
# }

# set {
#     name  = "vpcId"
#     value = data.data.aws_vpc.app.id
# }

# set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
# }

# set {
#     name  = "serviceAccount.create"
#     value = "false"
# }

# set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
# }

# set {
#     name  = "clusterName"
#     value = var.cluster_name
# }
# }
################################################################################
# EKS Cluster
################################################################################

# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster"
#   value       = module.eks.cluster_arn
# }

# output "cluster_certificate_authority_data" {
#   description = "Base64 encoded certificate data required to communicate with the cluster"
#   value       = module.eks.cluster_certificate_authority_data
# }

# output "cluster_endpoint" {
#   description = "Endpoint for your Kubernetes API server"
#   value       = module.eks.cluster_endpoint
# }

# output "oidc_provider" {
#   description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
#   value       = module.eks.oidc_provider
# }

# output "oidc_provider_arn" {
#   description = "The ARN of the OIDC Provider if `enable_irsa = true`"
#   value       = module.eks.oidc_provider_arn
# }



