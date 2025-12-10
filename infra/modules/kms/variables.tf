variable "name" {
  description = "Name of the KMS key"
  type        = string
}

variable "alias_name" {
  description = "Alias name for the KMS key"
  type        = string
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for encryption"
}

variable "deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

