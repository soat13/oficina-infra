variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "oficina"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags padrão"
  type        = map(string)
  default = {
    Name       = "Oficina"
    Enviroment = "Develop"
  }
}

# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------

variable "db_engine" {
  description = "Engine do banco de dados"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "17.6"
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado em GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_username" {
  description = "Usuário master do banco de dados"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_backup_retention" {
  description = "Dias de retenção de backup"
  type        = number
  default     = 0
}

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------

variable "s3_force_destroy" {
  description = "Forçar destruição do s3"
  type        = bool
  default     = false
}
