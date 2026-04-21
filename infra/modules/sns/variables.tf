variable "name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "fifo_topic" {
  description = "Whether the topic is a FIFO topic"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "The JSON-encoded delivery policy for the topic"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "Map of SQS subscriptions to create for the topic."
  type = map(object({
    endpoint             = string
    raw_message_delivery = optional(bool, true)
  }))
  default = {}
}

variable "topic_policy" {
  description = "Optional JSON-encoded resource policy attached via aws_sns_topic_policy. Use to restrict who can Publish/Subscribe. When null, AWS's default topic policy applies."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
