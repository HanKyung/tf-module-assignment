
data "aws_availability_zones" "available"{
    state = "available"
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  # can use nameregex too

#  can have multiple filter blocks to refine values step by step
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

output "stphn_ami_id" {
  value = data.aws_ami.amzn-linux-2023-ami.arn
  
}


##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
data "aws_vpc" "app" {
  # cidr_block           = var.vpc_cidr_block

#   tags = {
#     # local.common_tags
#     Name = "stphn-vpc-24072024"
# }

tags = {
  "Name" = "stphn-vpc-24072024"}
  
}
  


# resource "aws_internet_gateway" "app" {
#   vpc_id = data.aws_vpc.app.id

#    tags = merge(local.common_tags, {
#     Name = "${local.naming_prefix}-igw"
#   })
# }


#igw
data "aws_internet_gateway" "app" {
  # vpc_id = data.aws_vpc.app.id

  tags = {
    Name = "stphn24072024-tf-igw"
  }
}

# loop and create public subnet for each block
resource "aws_subnet" "public_subnets" {
  count = var.vpc_public_subnet_count
  # cidr_block              = var.vpc_public_subnets_cidr_block[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  vpc_id                  = data.aws_vpc.app.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]

   tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-subnet-${count.index}"
  })
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = data.aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.app.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-rtb"
  })
}

resource "aws_route_table_association" "app_public_subnets" {
  count = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "${local.naming_prefix}-nginx_sg"
  vpc_id = data.aws_vpc.app.id

  # required for ssh to EC2
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}



resource "aws_security_group" "alb_sg" {
  name   = "${local.naming_prefix}-nginx_alb_sg"
  vpc_id = data.aws_vpc.app.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# module "stephen-assessment-vpc" {
#   source = "terraform-aws-modules/vpc/aws"
# #   added version
#   version = "5.13.0"

#   name = "stphn-vpc-24072024"
#   cidr = var.vpc_cidr_block

#   azs             =  slice(data.aws_availability_zones.available.names, 0, var.vpc_public_subnet_count)
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# #   hard coded the bits
#   public_subnets  = [for subnet in range(var.vpc_public_subnet_count): cidrsubnet(var.vpc_cidr_block, 8, subnet)]

#   enable_nat_gateway = true
#   single_nat_gateway = true
#   enable_vpn_gateway = true
#   map_public_ip_on_launch =  var.map_public_ip_on_launch


#   tags = {
#     Terraform = "true"  
#     Environment = "dev"
#   }
# }
