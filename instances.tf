
resource "aws_instance" "stphn-tf-ec2-assessment" {
    count = var.instance_count
    ami = data.aws_ami.amzn-linux-2023-ami.id
    instance_type = var.instance_type
    # subnet_id = aws_subnet.stphn24072024-tf-public-subnet-us-east-1a.id
    subnet_id = aws_subnet.public_subnets[(count.index % var.vpc_public_subnet_count)].id
    associate_public_ip_address = true
    # key_name = "stphn-ec2-20072024"
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    availability_zone = "us-east-1a"

    user_data =  <<EOF
    #!bin/bash
    yum update -y
    yum install httpd -y
    yum install docker -y
    EOF

    tags = {
    Name = "stphn-tf-ec2"
  }
}