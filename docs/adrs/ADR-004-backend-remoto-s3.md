# ADR-004: Backend Remoto S3 para State do Terraform

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O Terraform mantém um arquivo de estado (`terraform.tfstate`) que mapeia os recursos declarados no código aos recursos reais na AWS. É necessário decidir onde armazenar esse state:

1. **Local (filesystem)** — padrão do Terraform, state no diretório do projeto
2. **S3 + DynamoDB** — backend remoto com locking
3. **Terraform Cloud** — backend managed pela HashiCorp
4. **GitLab/GitHub** — state versionado no repositório

## Decisão

Utilizar **Amazon S3** como backend remoto para o state do Terraform.

```hcl
terraform {
  backend "s3" {
    bucket = "oficina-infra-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Justificativa

- **Colaboração:** múltiplos membros da equipe podem trabalhar no mesmo state sem conflitos
- **Persistência:** state armazenado em serviço durável (11 noves de durabilidade S3)
- **CI/CD:** pipeline do GitHub Actions precisa acessar o state de forma centralizada
- **Simplicidade:** S3 é fácil de configurar e não requer conta em plataforma adicional
- **Custo:** S3 é praticamente gratuito para arquivos de state pequenos

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Local | Inviável para equipes e CI/CD, risco de perda de dados |
| Terraform Cloud | Requer conta separada, free tier limitado |
| GitLab/GitHub state | Não suportado nativamente pelo Terraform |

## Consequências

### Positivas
- State centralizado e acessível pelo pipeline
- Durabilidade garantida pelo S3
- Possibilidade de habilitar versionamento do bucket para rollback

### Negativas
- Sem state locking (DynamoDB não configurado) — risco de corridas em applies simultâneos
- Necessidade de criar o bucket S3 manualmente antes do primeiro `terraform init`

## Melhorias Futuras

- Adicionar DynamoDB para state locking
- Habilitar versionamento e criptografia SSE no bucket S3
