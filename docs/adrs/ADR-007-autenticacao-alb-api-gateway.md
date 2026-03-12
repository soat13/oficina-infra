# ADR-007: Autenticação ALB ↔ API Gateway via Header Compartilhado

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

A arquitetura expõe a aplicação através de uma cadeia: **API Gateway → ALB → EKS Nodes**. O ALB é internet-facing e, sem proteção adicional, pode ser acessado diretamente, bypassando o API Gateway e suas camadas de segurança (autenticação Lambda Authorizer, throttling, etc.).

## Decisão

Implementar um mecanismo de **shared secret via header HTTP** (`X-Service-Token`):

1. **Geração do token:** `random_password` do Terraform (32 caracteres, sem caracteres especiais)
2. **API Gateway:** injeta automaticamente o header `X-Service-Token` em todas as requisições HTTP Proxy para o ALB
3. **ALB Listener Rules:** valida o header e retorna **403 Forbidden** para requisições sem o token correto

```hcl
resource "random_password" "service_token" {
  length  = 32
  special = false
}
```

## Justificativa

- **Simplicidade:** não requer certificados mTLS ou integração com serviços adicionais
- **Eficiência:** validação no ALB (Layer 7) sem overhead no application code
- **Segurança imediata:** bloqueia acesso direto ao ALB, forçando tráfego pelo API Gateway
- **Automação:** token gerado e distribuído automaticamente pelo Terraform

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| mTLS entre API GW e ALB | Complexidade alta, não suportado nativamente pelo API Gateway REST |
| IP whitelisting | API Gateway usa IPs dinâmicos, inviável |
| AWS PrivateLink | Requer VPC endpoint, complexidade e custo adicionais |
| Security Group restritivo | API Gateway REST não possui ENI em VPC |

## Consequências

### Positivas
- Acesso direto ao ALB bloqueado efetivamente
- Zero alteração no código da aplicação
- Token rotacionável via `terraform apply`

### Negativas
- Token trafega em texto plano no header HTTP (mitigado com migração para HTTPS — ver RFC-001)
- Token armazenado no Terraform state (requer state criptografado)
- Não substitui autenticação real de usuários (papel do Lambda Authorizer)
