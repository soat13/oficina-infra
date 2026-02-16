variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "load_balancer_uri" {
  description = "URI of the Load Balancer to integrate with"
  type        = string
}

variable "service_token" {
  description = "Shared secret token for ALB authentication"
  type        = string
  sensitive   = true
}
