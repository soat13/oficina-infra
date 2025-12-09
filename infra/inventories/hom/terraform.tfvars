project_name = "oficina"
environment  = "hom"
aws_region   = "us-east-1"

aws_account_id = "610276426093"

tags = {
  Project     = "Oficina"
  Environment = "Homolog"
}

# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------

db_engine         = "postgres"
db_engine_version = "17.6"
db_instance_class = "db.t3.medium"

db_allocated_storage = 20

db_name     = "oficina"
db_username = "postgres"
db_password = "Oficina@123"

db_backup_retention = 7

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------

bucket_force_destroy = false