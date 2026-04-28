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

variable "node_port" {
  description = "The NodePort the main application is listening on"
  type        = number
  default     = 30007
}

variable "auth_node_port" {
  description = "The NodePort the auth application is listening on"
  type        = number
  default     = 30008
}

variable "webhook_node_port" {
  description = "The NodePort the auth application is listening on"
  type        = number
  default     = 30009
}
