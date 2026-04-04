output "queue_id" {
  description = "The URL for the created SQS queue"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.this.name
}

output "dlq_queue_id" {
  description = "The URL for the created DLQ"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_queue_arn" {
  description = "The ARN of the DLQ"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_queue_name" {
  description = "The name of the DLQ"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}
