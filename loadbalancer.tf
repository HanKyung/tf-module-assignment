# # aws_lb
# resource "aws_lb" "nginx" {
#   name               = "${local.naming_prefix}-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = aws_subnet.public_subnets[*].id

#   enable_deletion_protection = false

#   tags = local.common_tags
# }

# # aws_lb_target_group
# resource "aws_lb_target_group" "nginx" {
#   name     = "nginx-alb-tg"
#   port     = 80
#   protocol = "HTTP"
#   # vpc_id   = module.stephen-assessment-vpc.vpc_id
#   vpc_id = data.aws_vpc.app.id
#   tags = local.common_tags
# }

# # aws_lb_listener
# resource "aws_lb_listener" "nginx" {
#   load_balancer_arn = aws_lb.nginx.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nginx.arn
#   }

#   tags = local.common_tags
# }

# # One attachment for one EC2 instance

# # aws_lb_target_group_attachment
# resource "aws_lb_target_group_attachment" "nginx1" {
#   count = var.instance_count
#   target_group_arn = aws_lb_target_group.nginx.arn
#   target_id        = aws_instance.stphn-tf-ec2-assessment[count.index].id
#   port             = 80
# }

