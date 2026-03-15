# RFC-001: Migrar Network Load Balancer (NLB) para Application Load Balancer (ALB)

- **Status:** Proposto
- **Data:** 2026-03-11
- **Autor:** Equipe FIAP SOAT
- **Prioridade:** Alta

## Resumo

Migrar o **Network Load Balancer (NLB)** atual para um **Application Load Balancer (ALB)** para obter maior controle sobre o tráfego HTTP, funcionalidades avançadas de roteamento e melhor integração com serviços AWS de camada 7.

## Motivação

O NLB opera na **camada 4 (TCP/UDP)**, encaminhando pacotes sem inspeção de conteúdo. Embora tenha excelente performance e latência ultra-baixa, ele possui limitações para uma aplicação HTTP/REST:

- **Sem roteamento por path/host:** não é possível rotear `/api/v1/*` para um target group e `/api/v2/*` para outro
- **Sem inspeção de headers:** não é possível validar headers HTTP como `X-Service-Token` (ver ADR-007)
- **Sem redirecionamento HTTP → HTTPS:** redirect nativo não disponível no NLB
- **Sem sticky sessions baseadas em cookies:** NLB usa IP-based stickiness apenas
- **Sem modificação de response:** não é possível adicionar headers de segurança (HSTS, X-Frame-Options)

## Comparação NLB vs ALB

| Critério | NLB (Layer 4) | ALB (Layer 7) |
|---|---|---|
| Camada OSI | 4 (TCP/UDP) | 7 (HTTP/HTTPS) |
| Roteamento por path/host | ❌ | ✅ |
| Inspeção de headers | ❌ | ✅ |
| Redirect HTTP→HTTPS | ❌ | ✅ |
| Autenticação (OIDC/Cognito) | ❌ | ✅ |
| Sticky Sessions (cookie) | ❌ | ✅ |
| IP estático (Elastic IP) | ✅ | ❌ |
| Latência | ~μs (ultra-baixa) | ~ms (baixa) |
| TLS termination | ✅ | ✅ |
| Custo (por LCU/NLCU) | ~$0.006/NLCU‑hora | ~$0.008/LCU‑hora |
| Preserve source IP | ✅ (nativo) | Via `X-Forwarded-For` |

## Proposta

### 1. Criar Módulo ALB

```hcl
# modules/alb/main.tf

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"  # Mudança de "network" para "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "main" {
  name_prefix = "app-"
  port        = 30007
  protocol    = "HTTP"  # Mudança de "TCP" para "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"  # Health check HTTP (não disponível no NLB com TCP)
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}
```

### 2. Adicionar Listener Rules para Validação de Header

Com ALB, é possível implementar a validação do `X-Service-Token` diretamente no listener (ADR-007):

```hcl
resource "aws_lb_listener_rule" "validate_token" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  condition {
    http_header {
      http_header_name = "X-Service-Token"
      values           = [var.service_token]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Bloquear requisições sem token válido
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"error\": \"Forbidden\"}"
      status_code  = "403"
    }
  }
}
```

### 3. Habilitar Health Checks HTTP

Uma das grandes vantagens do ALB é o health check na camada 7:

```hcl
health_check {
  path                = "/health"
  protocol            = "HTTP"
  matcher             = "200"        # Verifica resposta HTTP 200
  healthy_threshold   = 2
  unhealthy_threshold = 3
}
```

## Impacto

| Componente | Mudança |
|---|---|
| `modules/alb/main.tf` | `load_balancer_type` de `"network"` para `"application"` |
| `modules/alb/main.tf` | Adicionar Security Group (ALB requer, NLB não) |
| `modules/alb/main.tf` | Listener rules para validação de headers |
| `modules/alb/main.tf` | Target group protocol de `TCP` para `HTTP` |
| `modules/alb/main.tf` | Health check HTTP com path `/health` |
| `main.tf` | Passar `vpc_id` e `service_token` para o módulo ALB |
| API Gateway | Integração HTTP Proxy permanece igual (usa DNS name do LB) |

## Plano de Migração

```
1. Criar ALB em paralelo ao NLB existente
2. Configurar Target Group HTTP apontando para os mesmos nodes
3. Testar ALB com tráfego de teste
4. Atualizar API Gateway para apontar para o DNS do ALB
5. Validar tráfego end-to-end
6. Remover NLB antigo
7. Cleanup de recursos órfãos
```

> ⚠️ **Atenção:** A migração envolve mudança de DNS do load balancer. Planejar janela de manutenção ou usar weighted routing no Route53 para migração gradual.

## Riscos

- **Downtime durante migração:** mitigar com criação do ALB em paralelo antes de trocar o DNS
- **IP estático:** NLB suporta Elastic IPs, ALB não. Se consumidores dependem de IP fixo, usar Global Accelerator
- **Latência:** ALB tem latência ligeiramente maior que NLB (ms vs μs), negligível para APIs REST
- **Security Group:** ALB requer Security Group (NLB não precisa), mais um recurso para gerenciar

## Funcionalidades Desbloqueadas

Com o ALB, as seguintes RFCs tornam-se viáveis:
- **ADR-007 (Header Auth):** validação de `X-Service-Token` nativa no listener
- **HTTPS futuro:** TLS termination com certificado ACM

## Critérios de Aceite

- [ ] ALB provisionado com `load_balancer_type = "application"`
- [ ] Security Group configurado permitindo HTTP/HTTPS
- [ ] Target Group com protocol HTTP e health check em `/health`
- [ ] Listener rules validando header `X-Service-Token`
- [ ] Requisições sem token retornam 403
- [ ] API Gateway comunicando com ALB via HTTP Proxy
- [ ] NLB antigo removido após validação
- [ ] Testes end-to-end passando
