variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "existing_cluster_role_arn" {
  description = "ARN of existing IAM role for EKS cluster (required)"
  type        = string
  default = "arn:aws:iam::590183784559:role/LabRole"
}

variable "existing_node_role_arn" {
  description = "ARN of existing IAM role for EKS nodes (required)"
  type        = string
  default = "arn:aws:iam::590183784559:role/LabRole"
}

variable "attach_policies" {
  description = "Whether to attach AWS managed policies to existing roles (set to false if you don't have permission to modify roles)"
  type        = bool
  default     = false
}

variable "create_policies" {
  description = "Whether to create custom IAM policies (set to false if you don't have permission to create policies)"
  type        = bool
  default     = false
}

variable "enable_secrets_manager_access" {
  description = "Enable Secrets Manager access for nodes (requires create_policies=true or use existing policy ARN)"
  type        = bool
  default     = false
}

variable "secrets_manager_secret_arns" {
  description = "List of Secrets Manager secret ARNs that nodes can access"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for Secrets Manager decryption"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

