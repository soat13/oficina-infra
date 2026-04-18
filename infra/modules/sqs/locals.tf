locals {
  queue_name = var.fifo_queue ? "${var.name}.fifo" : var.name
  dlq_name   = var.fifo_queue ? "${var.name}-dlq.fifo" : "${var.name}-dlq"
}
