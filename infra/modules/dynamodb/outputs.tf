output "arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}
