# # SECURITY GROUPS #
# # EC2 security group 
# resource "aws_security_group" "nginx_sg" {
#   name   = "${local.naming_prefix}-nginx_sg"
#   vpc_id = module.stephen-assessment-vpc.vpc_id

# # required for ssh to EC2
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr_block]
#   }

#   # outbound internet access
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.common_tags
# }

# resource "aws_security_group" "alb_sg" {
#   name   = "${local.naming_prefix}-nginx_alb_sg"
#   vpc_id = module.stephen-assessment-vpc.vpc_id

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # outbound internet access
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }