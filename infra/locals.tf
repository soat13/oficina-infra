data "aws_caller_identity" "current" {}

locals {
  sqs_queue_keys = keys(var.sqs_queues)

  sns_topic_arns = {
    for topic_name, cfg in var.sns_topics :
    topic_name => format(
      "arn:aws:sns:%s:%s:%s",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      cfg.fifo_topic ? "${topic_name}.fifo" : topic_name
    )
  }

  queue_source_topic_arns = {
    for queue_name in local.sqs_queue_keys :
    queue_name => [
      for topic_name, cfg in var.sns_topics :
      local.sns_topic_arns[topic_name]
      if contains(cfg.subscribers, queue_name)
    ]
  }
}