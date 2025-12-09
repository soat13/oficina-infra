project_name = "oficina"
environment  = "prod"
aws_region   = "us-east-1"

aws_account_id = "610276426093"

tags = {
  Project     = "Oficina"
  Environment = "Production"
  Critical    = "true"
}

# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------

db_engine         = "postgres"
db_engine_version = "17.6"
db_instance_class = "db.t3.medium"

db_allocated_storage = 50

db_name     = "oficina"
db_username = "postgres"
db_password = "Oficina@123"

db_backup_retention = 30

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------

bucket_force_destroy = false