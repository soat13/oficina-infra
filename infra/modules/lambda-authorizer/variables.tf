variable "name" {
  description = "Name for the lambda function and role"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the zipped Go binary (bootstrap)"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the lambda function"
  type        = map(string)
  default     = {}
}


variable "lambda_role_arn" {
  description = "The ARN of the IAM role to use for the Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
