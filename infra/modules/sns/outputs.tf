output "topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "topic_arn_base" {
  description = "The ARN prefix for SNS topics"
  value       = trimsuffix(aws_sns_topic.this.arn, ":${aws_sns_topic.this.name}")
}
