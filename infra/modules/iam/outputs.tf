output "eks_cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = var.existing_cluster_role_arn
}

output "eks_cluster_role_name" {
  description = "IAM role name for EKS cluster"
  value       = data.aws_iam_role.existing_cluster.name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS nodes"
  value       = var.existing_node_role_arn
}

output "eks_node_role_name" {
  description = "IAM role name for EKS nodes"
  value       = data.aws_iam_role.existing_node.name
}

output "secrets_manager_policy_arn" {
  description = "IAM policy ARN for Secrets Manager access"
  value       = var.enable_secrets_manager_access ? aws_iam_policy.eks_node_secrets_manager[0].arn : null
}

