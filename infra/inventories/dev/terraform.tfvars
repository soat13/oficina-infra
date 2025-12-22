aws_region = "us-east-1"

cluster_name = "fiap-eks-cluster-dev"

kubernetes_version = "1.33"

vpc_cidr = "10.0.0.0/16"

availability_zones_count = 2

kms_deletion_window = 7

cluster_endpoint_public_access = true

cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]


enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

log_retention_days = 7

node_instance_types = ["t3.medium"]

node_ami_type = "AL2023_x86_64_STANDARD"

node_capacity_type = "ON_DEMAND"

node_disk_size = 20

node_desired_size = 2

node_max_size = 4

node_min_size = 1

node_max_unavailable = 1

node_labels = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Workload    = "general"
}

existing_cluster_role_arn = "arn:aws:iam::590183784559:role/LabRole"

existing_node_role_arn = "arn:aws:iam::590183784559:role/LabRole"

attach_iam_policies = false

create_iam_policies = false

# RDS PostgreSQL Configuration
rds_database_name = "postgres"

# rds_master_username = "postgres"

# rds_master_password = "ChangeMe123!"

rds_engine_version = "16.10"

rds_instance_class = "db.t3.micro"

rds_allocated_storage = 20

rds_max_allocated_storage = 100

rds_storage_type = "gp3"

rds_availability_zone = null

rds_maintenance_window = "mon:04:00-mon:05:00"

rds_skip_final_snapshot = true

rds_deletion_protection = false

rds_enabled_cloudwatch_logs_exports = ["postgresql"]

tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "oficina"
}
