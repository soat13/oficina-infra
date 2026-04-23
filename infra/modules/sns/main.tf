resource "aws_sns_topic" "this" {
  name = local.topic_name

  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic

  kms_master_key_id = var.kms_master_key_id
  delivery_policy   = var.delivery_policy

  tags = merge(
    var.tags,
    {
      Name = local.topic_name
    }
  )
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  protocol  = "sqs"
  topic_arn = aws_sns_topic.this.arn
  endpoint  = each.value.endpoint

  raw_message_delivery = each.value.raw_message_delivery
}

resource "aws_sns_topic_policy" "this" {
  count = var.topic_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}
