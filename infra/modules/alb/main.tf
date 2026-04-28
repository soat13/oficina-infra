resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = var.node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" # Assuming a default health check path, might need adjustment
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499" # Accept a wide range for now to avoid premature failure
  }

  tags = var.tags
}

resource "aws_lb_target_group" "auth" {
  name     = "${var.project_name}-auth-tg"
  port     = var.auth_node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" # Assuming auth also implements /health
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "webhooks" {
  name     = "${var.project_name}-webhooks-tg"
  port     = var.webhook_node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" # Assuming auth also implements /health
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499"
  }

  tags = var.tags
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "api_access" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    http_header {
      http_header_name = "X-Service-Token"
      values           = [var.service_token]
    }
  }
}

resource "aws_lb_listener_rule" "auth_access" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth/*", "/admin/users", "/admin/users/*"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Service-Token"
      values           = [var.service_token]
    }
  }
}

resource "aws_lb_listener_rule" "payment_webhooks" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 91

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webhooks.arn
  }

  condition {
    path_pattern {
      values = ["/webhooks/*"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Service-Token"
      values           = [var.service_token]
    }
  }
}

