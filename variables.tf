
variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in VPC"
  default     = true
}

variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
  # default     = "10.0.0.0/16"
  default = "10.0.0.0/16"
}

variable "vpc_public_subnet_count" {
  type        = number
  description = "Number of public subnets to create."
  default     = 2
}

variable "vpc_public_subnets_cidr_block" {
  type        = list(string)
  description = "CIDR Block for Public Subnets in VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  # default = [for subnet in range(var.vpc_public_subnet_count): cidrsubnet(var.vpc_cidr_block, 8, subnet)]
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map a public IP address for Subnet instances"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "Type for EC2 Instance"
  default     = "t2.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "Globomantics"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default     = "CE7"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
  default     = "CE7"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
  default     = "globo-web-app"
}

variable "environment" {
  type        = string
  description = "Environment for deployment"
  default     = "development"
}



################################################################################
# Default Variables
################################################################################

variable "profile" {
  type    = string
  default = "default"
}
################################################################################
# EKS Cluster Variables
################################################################################

variable "cluster_name" {
  type    = string
  default = "tf-cluster"
}

variable "rolearn" {
  description = "Add admin role to the aws-auth configmap"
  default     = "CE7"
}

################################################################################
# ALB Controller Variables
################################################################################

variable "env_name" {
  type    = string
  default = "dev"
}

variable "aws_role_arn" {
  type    = string
  default = "arn:aws:iam::255945442255:role/stephen-tf-cluster-cluster-20241011194319139900000005"
}

# variable "db_subnet_group_name" {
#   type=string
#   default = "value"
# }

################################################################################
# Lambda  Variables
################################################################################
variable "lambda_function_name" {
  description = "Name of lambda function"
  type        = string
  default     = "stephen-initDBFunction"
}

variable "lambda_file_name" {
  description = "Name of lambda file to be zipped"
  type        = string
  default     = "stephen-init-rds-lambda-fn"
}