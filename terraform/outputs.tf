output "sns_topic_arn" {
    description = "The ARN of the SNS topic"
    value       = aws_sns_topic.sns_topic.arn
}

output "lambda_function_name" {
    description = "The name of the Lambda function"
    value       = aws_lambda_function.lambda_function.function_name
}

output "ec2_instance_id" {
    description = "The ID of the EC2 instance"
    value       = aws_instance.ec2_instance.id
}
