# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  ami_type        = var.ami_type
  capacity_type   = var.capacity_type
  disk_size       = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  dynamic "remote_access" {
    for_each = var.ssh_key != null || length(var.remote_access_source_security_groups) > 0 ? [1] : []
    content {
      ec2_ssh_key               = var.ssh_key
      source_security_group_ids = length(var.remote_access_source_security_groups) > 0 ? var.remote_access_source_security_groups : null
    }
  }

  labels = var.labels

  tags = merge(
    var.tags,
    {
      Name = var.node_group_name
    }
  )
}

