locals {
  queue_name = "${var.name}.fifo"
  dlq_name   = "${var.name}-dlq.fifo"
}
