# ADR-001: Uso do Amazon EKS como Plataforma de Orquestração

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O projeto necessita de uma plataforma para orquestrar containers da aplicação "Oficina" em ambiente AWS. As alternativas consideradas foram:

1. **Amazon ECS (Elastic Container Service)** — serviço gerenciado de containers AWS-nativo
2. **Amazon ECS com Fargate** — serverless containers, sem gerenciamento de instâncias
3. **Kubernetes self-managed (kops/kubeadm)** — controle total, mas overhead operacional alto
4. **Amazon EKS (Elastic Kubernetes Service)** — Kubernetes gerenciado pela AWS

## Decisão

Adotar o **Amazon EKS** como plataforma de orquestração de containers.

## Justificativa

- **Kubernetes como padrão de mercado:** portabilidade entre clouds e forte ecossistema (Helm, Kustomize, ArgoCD, Istio)
- **Gerenciamento do control plane pela AWS:** reduz complexidade operacional vs Kubernetes self-managed
- **Ecossistema de observabilidade:** integração nativa com ferramentas como Datadog, Prometheus e Grafana
- **Escalabilidade:** suporte a Cluster Autoscaler e Karpenter para auto-scaling de nodes
- **Alinhamento acadêmico:** Kubernetes é amplamente coberto no currículo FIAP e no mercado de trabalho

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| ECS | Menos portável, lock-in AWS, ecossistema menor |
| ECS + Fargate | Custo por vCPU mais alto, menor controle sobre networking |
| Kubernetes self-managed | Alta complexidade operacional para manter control plane |

## Consequências

### Positivas
- Flexibilidade e portabilidade da infraestrutura
- Grande ecossistema de tooling Kubernetes
- Facilidade de contratação de profissionais com experiência em K8s

### Negativas
- Custo fixo do control plane EKS (~$0.10/hora)
- Curva de aprendizado do Kubernetes para membros menos experientes
- Complexidade adicional em comparação com ECS para workloads simples
