



# import {
#   to = aws_iam_role.AWSServiceRoleForAmazonEKS
#   id = "AWSServiceRoleForAmazonEKS"
# }


# # import{
# #   to = aws_iam_role_policy.AmazonEKSServiceRolePolicy
# #   id= "AmazonEKSServiceRolePolicy"
# # }

# # resource aws_iam_role_policy "AmazonEKSServiceRolePolicy"{
# #   role = aws_iam_role.AWSServiceRoleForAmazonEKS
# #   policy = {}
# # }

# # resource "aws_iam_role" "AWSServiceRoleForAmazonEKS" {
# #     name = "AWSServiceRoleForAmazonEKS"
# #     assume_role_policy = {
# #       managed_policy_arns =["arn:aws:iam::aws:policy/aws-service-role/AmazonEKSServiceRolePolicy"]

# #     }
# # }


# module "lb_role" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#  role_name                              = "stephen_eks_lb"
#  attach_load_balancer_controller_policy = true

#  oidc_providers = {
#      main = {
#      provider_arn               = aws_eks_cluster.CE7-Stephen.oidc_provider_arn
#      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#      }
#  }
#  }



# resource "kubernetes_service_account" "service-account" {
#  metadata {
#      name      = "aws-load-balancer-controller"
#      namespace = "kube-system"
#      labels = {
#      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#      "app.kubernetes.io/component" = "controller"
#      }
#      annotations = {
#      "eks.amazonaws.com/role-arn"               = module.lb_role.role_name.arn
#      "eks.amazonaws.com/sts-regional-endpoints" = "true"
#      }
#  }
#  }


# resource "aws_eks_cluster" "CE7-Stephen" {
#   name     = "CE7-Stephen"
#   role_arn = module.lb_role.role_name.arn

#   vpc_config {
#     subnet_ids = aws_subnet.public_subnets[*].id
#   }
# }

# resource "aws_eks_node_group" "Stephen-CE7-node-group" {
#   cluster_name    = aws_eks_cluster.CE7-Stephen.name
#   node_group_name = "Stephen-CE7-node-group"
#   node_role_arn   = module.lb_role.role_name.arn
#   subnet_ids      = aws_subnet.public_subnets[*].id

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   instance_types = ["t2.micro"]

# #   remote_access {
# #     ec2_ssh_key = "my-key"
# #   }

#   tags = {
#     Name = "CE7-stephen-node-group"
#   }
# }




# data "aws_eks_cluster_auth" "aws_iam_authenticator" {
#   name = aws_eks_cluster.CE7-Stephen.name
# }

# provider "kubernetes" {
#   alias = "eks"
#   host                   = aws_eks_cluster.CE7-Stephen.endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.CE7-Stephen.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token

# }


# resource "helm_release" "alb-controller" {
#  name       = "aws-load-balancer-controller"
#  repository = "https://aws.github.io/eks-charts"
#  chart      = "aws-load-balancer-controller"
#  namespace  = "kube-system"
#  depends_on = [
#      kubernetes_service_account.service-account
#  ]

#  set {
#      name  = "region"
#      value = var.aws_region
#  }

#  set {
#      name  = "vpcId"
#      value = aws_vpc.app.id
#  }

#  set {
#      name  = "image.repository"
#      value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
#  }

#  set {
#      name  = "serviceAccount.create"
#      value = "false"
#  }

#  set {
#      name  = "serviceAccount.name"
#      value = "aws-load-balancer-controller"
#  }

#  set {
#      name  = "clusterName"
#      value = aws_eks_cluster.CE7-Stephen.name
#  }
#  }


# # module "alb_ingress_controller" {
# #   source  = "iplabs/alb-ingress-controller/kubernetes"
# #   version = "3.4.0"

# #   providers = {
# #     kubernetes = "kubernetes.eks"
# #   }

# #   k8s_cluster_type = "eks"
# #   k8s_namespace    = "kube-system"

# #   aws_region_name  = var.aws_region
# #   k8s_cluster_name = aws_eks_cluster.CE7-Stephen.name
# # }