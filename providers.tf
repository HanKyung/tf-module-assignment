terraform {
  required_version = ">= 1.9.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.0"
    }
  }
}



# resource "aws_eks_cluster" "target" {
#   # name = "CE7-test"
#   name = module.eks.cluster_name
#   role_arn = var.aws_role_arn
#   vpc_config {
#     subnet_ids = module.stephen-assessment-vpc.public_subnets # aws_subnet.public_subnets[*].id

#   }
# }

# data "aws_eks_cluster_auth" "aws_iam_authenticator" {
#   name = aws_eks_cluster.target.name
# }

# for removing the alb_ingress_controller module
# provider "kubernetes" {
#   alias = "eks"
#   host                   = data.aws_eks_cluster.target.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token

# }


# Configure the AWS Provider
# Uncomment the region, access_key and secret_key if you are running locally
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # Update accordingly
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

# resource "null_resource" "update_kubeconfig" {
#   provisioner "local-exec" {
#     command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
#   # command = "aws eks --region ${var.aws_region} update-kubeconfig --name CE7-test"
#   # depends_on = [module.eks]
# }
# }
# provider "helm" {
#   alias = "stephen_cluster"
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#       command     = "aws"
#     }
#   }
# }

# resource "helm_release" "testchart" {
#   provider  = helm.stephen_cluster
#   name       = "testchart"
#   chart      = "../../../resources/testchart"
#   namespace  = "kube-system"
# }