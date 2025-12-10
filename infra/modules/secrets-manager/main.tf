# Secrets Manager Secret
resource "aws_secretsmanager_secret" "main" {
  name                    = var.secret_name
  description             = var.description
  recovery_window_in_days = var.recovery_window
  kms_key_id              = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name = var.secret_name
    }
  )
}

# Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "main" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string
}

