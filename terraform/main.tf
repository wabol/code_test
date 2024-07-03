provider "aws" {
    region = var.region
}

data "aws_caller_identity" "current" {}

# Create an SNS topic
resource "aws_sns_topic" "sns_topic" {
    name = "ec2-restart-notifications"
}

# Create an IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
    name = "lambda_ec2_restart_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# Attach the custom policy to the role
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_ec2_sns_policy"
  description = "Policy to allow EC2 reboot and SNS publish"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Action = [
          "ec2:RebootInstances"
        ],
        Resource = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:ec2-restart-notifications"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# add 
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn

}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the Lambda function
resource "aws_lambda_function" "lambda_function" {
    filename        = "lambda_function.zip"
    function_name   = "RestartEC2Instance"
    role            = aws_iam_role.lambda_role.arn
    handler         = "lambda_function.lambda_handler"
    runtime         = "python3.12"
    source_code_hash = filebase64sha256("lambda_function.zip")
    environment {
      variables = {
        EC2_INSTANCE_ID = aws_instance.ec2_instance.id 
        SNS_TOPIC_ARN   = aws_sns_topic.sns_topic.arn
      }
    }
}

# Create an ec2 instance
resource "aws_instance" "ec2_instance" {
    ami             = "ami-0c2644caf041bb6de"
    instance_type   = var.ec2_instance_type
    key_name        = var.ec2_key_name
    vpc_security_group_ids = [ var.security_group_id ]

    tags = {
        Name = "LambdaRestartEC2Instance"
    }
}