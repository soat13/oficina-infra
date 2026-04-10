output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.authorizer.arn
}

output "lambda_invoke_arn" {
  description = "The Invoke ARN of the Lambda function, to be passed to API Gateway"
  value       = aws_lambda_function.authorizer.invoke_arn
}


