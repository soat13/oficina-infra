locals {
  topic_name = var.fifo_topic ? "${var.name}.fifo" : var.name
}
