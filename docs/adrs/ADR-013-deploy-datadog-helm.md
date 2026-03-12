# ADR-013: Deploy do Datadog Agent via Helm no Pipeline CI/CD

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O Datadog Agent precisa ser instalado no cluster EKS. Existem diferentes abordagens:

1. **Kubectl apply (manifests YAML)** — deploy manual com manifests Kubernetes
2. **Helm chart** — gerenciamento de release com templates configuráveis
3. **Operator (Datadog Operator)** — CRD Kubernetes para gerenciamento declarativo
4. **GitOps (ArgoCD/Flux)** — reconciliação automática com repositório Git

## Decisão

Utilizar o **Helm chart oficial do Datadog** (`datadog/datadog`), deployado automaticamente pelo pipeline CI/CD no job `datadog-deploy`:

```bash
helm upgrade --install datadog-agent datadog/datadog \
  -f k8s/datadog/values.yaml \
  --set datadog.clusterName=$CLUSTER_NAME \
  --namespace datadog \
  --create-namespace
```

A configuração é personalizada via `k8s/datadog/values.yaml`.

## Justificativa

- **Helm chart oficial:** mantido pelo Datadog, atualizado com cada release
- **Configuração centralizada:** `values.yaml` no repositório, versionado e revisável
- **`upgrade --install`:** idempotente, cria ou atualiza conforme necessário
- **Automação completa:** integrado ao pipeline, deploy ocorre após `terraform-apply`
- **Secret seguro:** API key via Kubernetes Secret, referenciada no values

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Manifests YAML manuais | Verbose, propenso a erros, sem gestão de releases |
| Datadog Operator | Complexidade adicional de CRDs para projeto acadêmico |
| GitOps | Requer ArgoCD/Flux (ver RFC-008), no momento imperative é suficiente |

## Consequências

### Positivas
- Deploy automatizado e reproduzível
- Atualização simples via `helm upgrade`
- Configuração auditável no Git

### Negativas
- Deploy imperativo (não reconcilia automaticamente se alguém alterar manualmente)
- Helm tiller state armazenado no cluster (secrets no namespace)
