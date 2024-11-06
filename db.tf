

resource "aws_db_subnet_group" "default" {
  name       = "stephen-db-subnet-group"
  subnet_ids = module.stephen-assessment-vpc.public_subnets #[aws_subnet.default.id]
  tags = {
    Name = "stephen-db-subnet-group"
  }

}

resource "aws_db_instance" "friends_db_instance" {
  identifier             = "usermgmtdb"
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0.39"
  allocated_storage      = 20
  db_name                = "friends"
  username               = "dbadmin"
  password               = "dbpassword11"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.stephen_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  multi_az               = false
  publicly_accessible    = true

  # Explicit dependency on the VPC module
  depends_on = [module.stephen-assessment-vpc]
}


resource "aws_security_group" "stephen_rds_sg" {
  name        = "stephen-rds-sg"
  description = "RDS security group"
  vpc_id      = module.stephen-assessment-vpc.vpc_id

  # ingress for eks nodes
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.stephn_eks_nodes_sg.id]
    # cidr_blocks = [module.stephen-assessment-vpc.vpc_cidr_block]
  }

  # ingress for lambda function
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




# resource "null_resource" "db_init_script" {
#   provisioner "local-exec" {
#     command = "mysql -h ${aws_db_instance.friends_db_instance.address} -P 3306 -u dbadmin -pdbpassword11 usermgmtdb < init.sql"

#   }

#   depends_on = [aws_db_instance.friends_db_instance]
# }

