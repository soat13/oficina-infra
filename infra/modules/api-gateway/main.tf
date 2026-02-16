resource "aws_api_gateway_rest_api" "api" {
  name        = var.name
  description = "API Gateway for ${var.name}"

  body = templatefile("${path.module}/contrato/oficina.yaml", {
    load_balancer_uri = var.load_balancer_uri
    service_token     = var.service_token
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      templatefile("${path.module}/contrato/oficina.yaml", {
        load_balancer_uri = var.load_balancer_uri
        service_token     = var.service_token
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
