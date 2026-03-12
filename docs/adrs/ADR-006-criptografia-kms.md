# ADR-006: Criptografia de Secrets do EKS com KMS

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O Kubernetes armazena secrets (credenciais, tokens, certificados) no etcd. Por padrão, o EKS criptografa dados em repouso, mas com uma chave gerenciada pela AWS. É necessário decidir se uma chave KMS customizada deve ser usada.

## Decisão

Criar uma **chave KMS customizada** dedicada à criptografia de secrets do EKS:

- Alias: `{cluster-name}-eks`
- Janela de deleção: 30 dias (configurável)
- Habilitada via `encryption_config` no cluster EKS

## Justificativa

- **Controle:** chaves custom permitem definir políticas de acesso granulares
- **Auditoria:** CloudTrail registra todos os usos da chave KMS
- **Compliance:** atende requisitos de regulamentações que exigem controle sobre chaves de criptografia
- **Rotação:** possibilidade de rotação automática da chave KMS

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Chave padrão AWS | Menor controle, sem auditoria granular |
| Sem criptografia de secrets | Inaceitável do ponto de vista de segurança |

## Consequências

### Positivas
- Secrets criptografados com chave sob controle da equipe
- Rastreabilidade completa via CloudTrail
- Alinhamento com best practices AWS Well-Architected (pilar Segurança)

### Negativas
- Custo adicional da chave KMS (~$1/mês)
- Complexidade: deleção acidental da KMS key pode tornar secrets irrecuperáveis
