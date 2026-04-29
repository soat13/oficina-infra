# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name                     = var.cluster_name
  cluster_name             = var.cluster_name
  vpc_cidr                 = var.vpc_cidr
  availability_zones_count = var.availability_zones_count
  tags                     = var.tags
}

# KMS Module
module "kms" {
  source = "./modules/kms"

  name            = "${var.cluster_name}-kms-key"
  alias_name      = "${var.cluster_name}-eks"
  description     = "KMS key for EKS cluster encryption"
  deletion_window = var.kms_deletion_window
  tags            = var.tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name              = var.cluster_name
  aws_region                = var.aws_region
  existing_cluster_role_arn = var.existing_cluster_role_arn
  existing_node_role_arn    = var.existing_node_role_arn
  attach_policies           = var.attach_iam_policies
  create_policies           = var.create_iam_policies
  tags                      = var.tags
}

# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks-cluster"

  cluster_name                 = var.cluster_name
  cluster_role_arn             = module.iam.eks_cluster_role_arn
  kubernetes_version           = var.kubernetes_version
  vpc_id                       = module.vpc.vpc_id
  vpc_cidr                     = module.vpc.vpc_cidr
  private_subnet_ids           = module.vpc.private_subnet_ids
  kms_key_arn                  = module.kms.key_arn
  endpoint_public_access       = var.cluster_endpoint_public_access
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  log_retention_days           = var.log_retention_days
  tags                         = var.tags
}

# Node Group Module
module "node_group" {
  source = "./modules/node-group"

  cluster_name                         = var.cluster_name
  node_group_name                      = "${var.cluster_name}-node-group"
  node_role_arn                        = module.iam.eks_node_role_arn
  subnet_ids                           = module.vpc.private_subnet_ids
  instance_types                       = var.node_instance_types
  ami_type                             = var.node_ami_type
  capacity_type                        = var.node_capacity_type
  disk_size                            = var.node_disk_size
  desired_size                         = var.node_desired_size
  max_size                             = var.node_max_size
  min_size                             = var.node_min_size
  max_unavailable                      = var.node_max_unavailable
  node_security_group_id               = module.eks_cluster.node_security_group_id
  ssh_key                              = var.node_ssh_key
  remote_access_source_security_groups = var.node_remote_access_source_security_groups
  labels                               = var.node_labels
  tags                                 = var.tags

  depends_on = [
    module.iam,
    module.eks_cluster
  ]
}

# Generate Shared Secret for ALB-API Gateway Authentication
resource "random_password" "service_token" {
  length  = 32
  special = false
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  project_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = var.tags
  service_token     = random_password.service_token.result
}

# Attach Node Group ASG to ALB Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.node_group.autoscaling_group_names[0]
  lb_target_group_arn    = module.alb.target_group_arn
}

resource "aws_autoscaling_attachment" "auth_asg_attachment" {
  autoscaling_group_name = module.node_group.autoscaling_group_names[0]
  lb_target_group_arn    = module.alb.auth_target_group_arn
}

resource "aws_autoscaling_attachment" "webhooks_asg_attachment" {
  autoscaling_group_name = module.node_group.autoscaling_group_names[0]
  lb_target_group_arn    = module.alb.webhooks_target_group_arn
}

# API Gateway Module
module "lambda_authorizer" {
  source = "./modules/lambda-authorizer"

  name            = "${var.cluster_name}-authorizer"
  lambda_zip_path = var.lambda_zip_path
  lambda_role_arn = var.existing_lambda_role_arn
  tags            = var.tags

  env_vars = {
    AUTH_API_URL  = "${module.alb.dns_name}/auth/validate"
    SERVICE_TOKEN = random_password.service_token.result
  }
}

module "api_gateway" {
  source                 = "./modules/api-gateway"
  name                   = "${var.cluster_name}-api"
  stage_name             = "dev"
  tags                   = var.tags
  load_balancer_uri      = module.alb.dns_name
  service_token          = random_password.service_token.result
  auth_lambda_invoke_arn = module.lambda_authorizer.lambda_invoke_arn
}

# SQS Queues
module "sqs_queues" {
  source   = "./modules/sqs"
  for_each = var.sqs_queues

  name       = each.key
  fifo_queue = each.value.fifo_queue
  create_dlq = each.value.create_dlq

  # Enable High Throughput for FIFO queues by default
  deduplication_scope   = each.value.deduplication_scope != null ? each.value.deduplication_scope : (each.value.fifo_queue ? "messageGroup" : null)
  fifo_throughput_limit = each.value.fifo_throughput_limit != null ? each.value.fifo_throughput_limit : (each.value.fifo_queue ? "perMessageGroupId" : null)

  allowed_sns_source_arns = lookup(local.queue_source_topic_arns, each.key, [])

  kms_master_key_id = module.kms.key_arn

  tags = var.tags
}

# SNS Topics (fanout to SQS queues)
module "sns_topics" {
  source   = "./modules/sns"
  for_each = var.sns_topics

  name       = each.key
  fifo_topic = each.value.fifo_topic

  subscriptions = {
    for queue_name in each.value.subscribers :
    queue_name => {
      endpoint = module.sqs_queues[queue_name].queue_arn
    }
  }

  kms_master_key_id = module.kms.key_arn

  tags = var.tags
}

