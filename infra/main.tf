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
  ssh_key                              = var.node_ssh_key
  remote_access_source_security_groups = var.node_remote_access_source_security_groups
  labels                               = var.node_labels
  tags                                 = var.tags

  depends_on = [
    module.iam,
    module.eks_cluster
  ]
}

# RDS PostgreSQL Module
module "rds_postgres" {
  source = "./modules/rds-postgres"

  db_name                         = "${var.cluster_name}-postgres"
  vpc_id                          = module.vpc.vpc_id
  vpc_cidr                        = module.vpc.vpc_cidr
  subnet_ids                      = module.vpc.private_subnet_ids
  allowed_security_group_ids      = [module.eks_cluster.node_security_group_id]
  kms_key_id                      = module.kms.key_arn
  database_name                   = var.rds_database_name
  master_username                 = var.rds_master_username
  master_password                 = var.rds_master_password
  engine_version                  = var.rds_engine_version
  instance_class                  = var.rds_instance_class
  allocated_storage               = var.rds_allocated_storage
  max_allocated_storage           = var.rds_max_allocated_storage
  storage_type                    = var.rds_storage_type
  availability_zone               = var.rds_availability_zone
  maintenance_window              = var.rds_maintenance_window
  skip_final_snapshot             = var.rds_skip_final_snapshot
  deletion_protection             = var.rds_deletion_protection
  enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports
  tags                            = var.tags

  depends_on = [
    module.vpc,
    module.kms,
    module.eks_cluster
  ]
}