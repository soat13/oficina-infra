data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "api" {
  name        = var.name
  description = "API Gateway for ${var.name}"

  body = templatefile("${path.module}/contract/oficina.yaml", {
    load_balancer_uri      = var.load_balancer_uri
    service_token          = var.service_token
    auth_lambda_invoke_arn = var.auth_lambda_invoke_arn
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# Extract the Lambda function name/ARN from the api gateway invoke ARN
locals {
  # Format: arn:aws:apigateway:REGION:lambda:path/2015-03-31/functions/LAMBDA_ARN/invocations
  lambda_arn = replace(replace(var.auth_lambda_invoke_arn, "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/", ""), "/invocations", "")
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      templatefile("${path.module}/contract/oficina.yaml", {
        load_balancer_uri      = var.load_balancer_uri
        service_token          = var.service_token
        auth_lambda_invoke_arn = var.auth_lambda_invoke_arn
      }),
      var.stage_name
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name

  tags = var.tags
}
