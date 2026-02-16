variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs for ALB"
  type        = list(string)
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "service_token" {
  description = "Shared secret token for API Gateway authentication"
  type        = string
  sensitive   = true
}
