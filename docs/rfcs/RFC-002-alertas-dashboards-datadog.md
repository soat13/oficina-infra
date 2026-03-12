# RFC-003: Alertas e Dashboards Automatizados no Datadog

- **Status:** Proposto
- **Data:** 2026-03-11
- **Autor:** Equipe FIAP SOAT
- **Prioridade:** Alta

## Resumo

Definir **SLOs/SLIs** e criar monitors (alertas) e dashboards automatizados no Datadog para monitoramento proativo da aplicação e infraestrutura.

## Motivação

O Datadog Agent está coletando métricas, logs e traces (ADR-013/014), porém não há:

- Alertas configurados para condições críticas
- Dashboards para visibilidade operacional
- SLOs definidos para medir confiabilidade
- Runbooks para resposta a incidentes

## Proposta

### 1. Definição de SLIs/SLOs

| SLI (Indicador) | SLO (Objetivo) | Janela |
|---|---|---|
| Disponibilidade da API (HTTP 2xx/total) | 99.5% | 30 dias |
| Latência P99 do API Gateway | < 500ms | 30 dias |
| Taxa de erro 5xx | < 1% | 7 dias |
| Uptime dos pods (Running/Total) | 99.9% | 30 dias |

### 2. Monitors (Alertas)

#### Infraestrutura
```yaml
monitors:
  - name: "[EKS] Node Not Ready"
    type: metric alert
    query: "avg(last_5m):avg:kubernetes.node.status.ready{cluster_name:fiap-*} < 1"
    message: "Node não está Ready. Verificar instância EC2."
    thresholds:
      critical: 1

  - name: "[EKS] Pod CrashLoopBackOff"
    type: metric alert
    query: "avg(last_5m):avg:kubernetes.containers.restarts{cluster_name:fiap-*} > 5"
    message: "Container reiniciando repetidamente."

  - name: "[EKS] High CPU Usage"
    type: metric alert
    query: "avg(last_10m):avg:kubernetes.cpu.usage.total{cluster_name:fiap-*} > 80"
    message: "CPU acima de 80% por 10 minutos."

  - name: "[EKS] High Memory Usage"
    type: metric alert
    query: "avg(last_10m):avg:kubernetes.memory.usage_pct{cluster_name:fiap-*} > 85"
    message: "Memória acima de 85% por 10 minutos."
```

#### Aplicação
```yaml
monitors:
  - name: "[API] High Error Rate"
    type: metric alert
    query: "avg(last_5m):sum:trace.http.request.errors{service:oficina-api} / sum:trace.http.request.hits{service:oficina-api} > 0.05"
    message: "Taxa de erro acima de 5%."

  - name: "[API] High Latency P99"
    type: metric alert
    query: "avg(last_5m):p99:trace.http.request.duration{service:oficina-api} > 0.5"
    message: "Latência P99 acima de 500ms."
```

### 3. Dashboard Operacional

Criar dashboard com widgets:

- **Visão Geral:** status dos pods, nodes ready, cluster health
- **Tráfego:** requests/s, errors/s, latência P50/P95/P99
- **Recursos:** CPU, memória, disk por node e por pod
- **Logs:** top errors, log volume por serviço
- **APM:** service map, endpoints mais lentos, traces de erro

### 4. Automação via Terraform (Datadog Provider)

```hcl
provider "datadog" {
  api_key = var.dd_api_key
  app_key = var.dd_app_key
}

resource "datadog_monitor" "high_error_rate" {
  name    = "[API] High Error Rate"
  type    = "metric alert"
  query   = "avg(last_5m):..."
  message = "Taxa de erro acima de 5%. @slack-alerts"

  monitor_thresholds {
    critical = 0.05
    warning  = 0.03
  }
}
```

## Critérios de Aceite

- [ ] SLOs definidos e configurados no Datadog
- [ ] Pelo menos 6 monitors ativos (3 infra + 3 app)
- [ ] Dashboard operacional criado e acessível
- [ ] Notificações configuradas (Slack ou email)
