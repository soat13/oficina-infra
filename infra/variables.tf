variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "fiap-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS cluster endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}


variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "node_instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_ami_type" {
  description = "AMI type for the node group. For Kubernetes 1.33+, use AL2023_x86_64_STANDARD, AL2023_ARM_64_STANDARD, BOTTLEROCKET_x86_64, or BOTTLEROCKET_ARM_64"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Disk size in GB for the node group"
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_max_unavailable" {
  description = "Maximum number of unavailable nodes during update"
  type        = number
  default     = 1
}

variable "node_ssh_key" {
  description = "EC2 SSH key pair name for node group remote access"
  type        = string
  default     = null
}

variable "node_remote_access_source_security_groups" {
  description = "List of security group IDs for node group remote access"
  type        = list(string)
  default     = []
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels to apply to nodes"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "existing_cluster_role_arn" {
  description = "ARN of existing IAM role for EKS cluster (required - no roles will be created)"
  type        = string
}

variable "existing_node_role_arn" {
  description = "ARN of existing IAM role for EKS nodes (required - no roles will be created)"
  type        = string
}

variable "attach_iam_policies" {
  description = "Whether to attach AWS managed policies to existing roles (set to false if you don't have permission to modify roles)"
  type        = bool
  default     = false
}

variable "create_iam_policies" {
  description = "Whether to create custom IAM policies (set to false if you don't have permission to create policies)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "fiap-soat"
  }
}

variable "auth_lambda_invoke_arn" {
  description = "The Invoke ARN of the Identity Lambda required by API Gateway"
  type        = string
}

variable "sqs_queues" {
  description = "Map of SQS queues to be created"
  type = map(object({
    fifo_queue = optional(bool, false)
    create_dlq = optional(bool, true)
  }))
  default = {}
}

