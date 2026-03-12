# ADR-012: Datadog como Plataforma de Observabilidade

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O cluster EKS precisa de uma solução de observabilidade que cubra métricas, logs e traces (os três pilares). Opções consideradas:

1. **Amazon CloudWatch** — observabilidade nativa AWS
2. **Prometheus + Grafana** — stack open-source de métricas e dashboards
3. **ELK Stack (Elasticsearch + Logstash + Kibana)** — stack open-source de logs
4. **Datadog** — plataforma SaaS unificada de observabilidade
5. **New Relic** — plataforma SaaS de APM e observabilidade

## Decisão

Adotar **Datadog** como plataforma unificada de observabilidade, com as seguintes features habilitadas:

- **APM (Application Performance Monitoring)** — traces das aplicações
- **Logs** — agregação automática de logs de todos os containers
- **Orchestrator Explorer** — visibilidade sobre pods, deployments e recursos K8s
- **Cluster Agent** — com PodDisruptionBudget para alta disponibilidade

## Justificativa

- **Plataforma unificada:** métricas, logs e traces em uma única ferramenta
- **Integração nativa com K8s:** Datadog Agent como DaemonSet com auto-discovery
- **Operação zero:** SaaS, sem necessidade de gerenciar Prometheus, Grafana ou Elasticsearch
- **Dashboards prontos:** dashboards pré-configurados para EKS, containers e AWS
- **Alerting:** sistema de alertas robusto com integrações (Slack, PagerDuty, email)

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| CloudWatch | Limitado para correlação entre métricas/logs/traces |
| Prometheus + Grafana | Exige gestão de infra (Prometheus server, persistent storage) |
| ELK Stack | Alta complexidade operacional, consumo intenso de memória |
| New Relic | Funcionalidade similar ao Datadog, mas menor adoção em K8s |

## Consequências

### Positivas
- Visibilidade completa do stack em uma única plataforma
- Correlação automática entre métricas, logs e traces
- Helm chart simplifica deploy e atualizações
- Reduz MTTR (Mean Time To Resolution) com dashboards e alertas

### Negativas
- **Custo:** Datadog é caro em produção (billing por host/log volume)
- Dependência de serviço SaaS externo (dados enviados para cloud Datadog)
- API key deve ser gerenciada como secret sensível
