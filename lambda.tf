# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "./files/${var.lambda_file_name}.py"
#   output_path = "./files/${var.lambda_file_name}.zip"
# }

resource "aws_lambda_function" "init_db" {
  filename         = "./files/${var.lambda_file_name}.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = filebase64sha256("./files/${var.lambda_file_name}.zip")

  environment {
    variables = {
      RDS_HOST     = split(aws_db_instance.friends_db_instance.endpoint, ":")[0] #"your-rds-endpoint" without the port number
      RDS_USER     = aws_db_instance.friends_db_instance.username                #"username"
      RDS_PASSWORD = aws_db_instance.friends_db_instance.password                #"password"
      RDS_DB       = aws_db_instance.friends_db_instance.db_name                 #"dbname"
    }
  }

  vpc_config {
    subnet_ids         = module.stephen-assessment-vpc.public_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_security_group" "lambda_sg" {
  name        = "stephen-lambda_sg"
  description = "Allow Lambda access"
  vpc_id      = module.stephen-assessment-vpc.vpc_id

  # only outbound is required for lambda
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


