# Data source for existing cluster role
data "aws_iam_role" "existing_cluster" {
  name = split("/", var.existing_cluster_role_arn)[length(split("/", var.existing_cluster_role_arn)) - 1]
}

# Data source for existing node role
data "aws_iam_role" "existing_node" {
  name = split("/", var.existing_node_role_arn)[length(split("/", var.existing_node_role_arn)) - 1]
}

# Attach AWS managed policy to existing cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.attach_policies ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = data.aws_iam_role.existing_cluster.name
}

# Attach AWS managed policies to existing node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count      = var.attach_policies ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = data.aws_iam_role.existing_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  count      = var.attach_policies ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = data.aws_iam_role.existing_node.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  count      = var.attach_policies ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = data.aws_iam_role.existing_node.name
}

