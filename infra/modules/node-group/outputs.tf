output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_capacity_type" {
  description = "Capacity type of the EKS node group"
  value       = aws_eks_node_group.main.capacity_type
}

output "autoscaling_group_names" {
  description = "List of AutoScaling Group names"
  value       = flatten([
    for rg in aws_eks_node_group.main.resources : [
      for asg in rg.autoscaling_groups : asg.name
    ]
  ])
}
