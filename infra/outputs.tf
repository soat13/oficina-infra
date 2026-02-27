output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks_cluster.cluster_version
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = module.node_group.node_group_id
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = module.node_group.node_group_arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.node_group.node_group_status
}

output "node_group_capacity_type" {
  description = "Capacity type of the EKS node group"
  value       = module.node_group.node_group_capacity_type
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for NAT Gateways and ELBs)"
  value       = module.vpc.public_subnet_ids
}

output "kms_key_id" {
  description = "KMS key ID used for EKS encryption"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for EKS encryption"
  value       = module.kms.key_arn
}

output "kms_alias" {
  description = "KMS key alias"
  value       = module.kms.alias_name
}

output "eks_cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS nodes"
  value       = module.iam.eks_node_role_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}

output "api_gateway_endpoint" {
  description = "URL to invoke the API Gateway"
  value       = module.api_gateway.invoke_url
}
