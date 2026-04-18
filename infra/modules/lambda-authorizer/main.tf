resource "aws_lambda_function" "authorizer" {
  function_name = var.name
  role          = var.lambda_role_arn

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  handler = "bootstrap"       # Required for AL2023 custom runtimes (Go)
  runtime = "provided.al2023" # Modern runtime for Go lambdas

  environment {
    variables = var.env_vars
  }

  tags = var.tags
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource within the API Gateway
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*/*"
}
