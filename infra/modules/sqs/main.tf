resource "aws_sqs_queue" "this" {
  name = var.name

  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? 300 : null

  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name = "${var.name}-dlq"

  message_retention_seconds = 1209600 # 14 days

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? 300 : null

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-dlq"
    }
  )
}
