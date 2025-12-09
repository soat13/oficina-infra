# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------

output "rds_endpoint" {
  description = "Endpoint completo do RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_host" {
  description = "Hostname/Address do RDS"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Porta do RDS PostgreSQL"
  value       = aws_db_instance.postgres.port
}

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.app_storage.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name do bucket S3"
  value       = aws_s3_bucket.app_storage.bucket_domain_name
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "ID do Security Group do PostgreSQL"
  value       = aws_security_group.postgres.id
}

output "security_group_arn" {
  description = "ARN do Security Group do PostgreSQL"
  value       = aws_security_group.postgres.arn
}