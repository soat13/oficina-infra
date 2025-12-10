# Data source for existing cluster role
data "aws_iam_role" "existing_cluster" {
  name = split("/", var.existing_cluster_role_arn)[length(split("/", var.existing_cluster_role_arn)) - 1]
}

# Data source for existing node role
data "aws_iam_role" "existing_node" {
  name = split("/", var.existing_node_role_arn)[length(split("/", var.existing_node_role_arn)) - 1]
}

# Attach AWS managed policy to existing cluster role (only if attach_policies is true)
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.attach_policies ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = data.aws_iam_role.existing_cluster.name
}

# Attach AWS managed policies to existing node role (only if attach_policies is true)
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

# Custom IAM policy for Secrets Manager access (least privilege) - only if create_policies is true
resource "aws_iam_policy" "eks_node_secrets_manager" {
  count       = var.enable_secrets_manager_access && var.create_policies ? 1 : 0
  name        = "${var.cluster_name}-node-secrets-manager-policy"
  description = "Policy for EKS nodes to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_secret_arns
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [var.kms_key_arn]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach Secrets Manager policy to existing node role (only if attach_policies is true and policy exists)
resource "aws_iam_role_policy_attachment" "eks_node_secrets_manager" {
  count      = var.enable_secrets_manager_access && var.attach_policies && var.create_policies ? 1 : 0
  policy_arn = aws_iam_policy.eks_node_secrets_manager[0].arn
  role       = data.aws_iam_role.existing_node.name
}

