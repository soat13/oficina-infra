# Documentação de Arquitetura — Oficina Infra

Este diretório contém a documentação formal de decisões arquiteturais e propostas de evolução do projeto.

## 📋 ADRs (Architecture Decision Records)

Documentam decisões de arquitetura **já adotadas** no projeto.

| # | Título | Status |
|---|--------|--------|
| [ADR-001](adrs/ADR-001-uso-do-amazon-eks.md) | Uso do Amazon EKS como Plataforma de Orquestração | ✅ Aceito |
| [ADR-002](adrs/ADR-002-terraform-como-iac.md) | Terraform como Ferramenta de IaC | ✅ Aceito |
| [ADR-003](adrs/ADR-003-arquitetura-modular-terraform.md) | Arquitetura Modular do Terraform | ✅ Aceito |
| [ADR-004](adrs/ADR-004-backend-remoto-s3.md) | Backend Remoto S3 para State do Terraform | ✅ Aceito |
| [ADR-005](adrs/ADR-005-vpc-subnets-publicas-privadas.md) | VPC com Subnets Públicas e Privadas | ✅ Aceito |
| [ADR-006](adrs/ADR-006-criptografia-kms.md) | Criptografia de Secrets do EKS com KMS | ✅ Aceito |
| [ADR-007](adrs/ADR-007-autenticacao-alb-api-gateway.md) | Autenticação ALB ↔ API Gateway via Header | ✅ Aceito |
| [ADR-008](adrs/ADR-008-uso-labrole-existente.md) | Uso de LabRole Existente vs Criação de IAM Roles | ✅ Aceito |
| [ADR-009](adrs/ADR-009-github-actions-cicd.md) | GitHub Actions como Plataforma de CI/CD | ✅ Aceito |
| [ADR-010](adrs/ADR-010-sonarcloud-analise-estatica.md) | SonarCloud como Ferramenta de Análise Estática | ✅ Aceito |
| [ADR-011](adrs/ADR-011-estrategia-deploy-plan-apply.md) | Estratégia de Deploy Plan → Apply Separados | ✅ Aceito |
| [ADR-012](adrs/ADR-012-datadog-observabilidade.md) | Datadog como Plataforma de Observabilidade | ✅ Aceito |
| [ADR-013](adrs/ADR-013-deploy-datadog-helm.md) | Deploy do Datadog Agent via Helm | ✅ Aceito |

## 📝 RFCs (Request for Comments)

Propostas de **melhorias e evoluções futuras** para discussão e aprovação da equipe.

### 🔒 Segurança & Rede

| # | Título | Prioridade |
|---|--------|-----------|
| [RFC-001](rfcs/RFC-001-migrar-alb-https.md) | Migrar NLB para ALB para Maior Controle e Funcionalidades | 🔴 Alta |

### 📊 Observabilidade

| # | Título | Prioridade |
|---|--------|-----------|
| [RFC-002](rfcs/RFC-002-alertas-dashboards-datadog.md) | Alertas e Dashboards Automatizados no Datadog | 🔴 Alta |

## Como Contribuir

### Novo ADR
1. Copie o template de um ADR existente
2. Numere sequencialmente (ADR-014, ADR-015...)
3. Preencha: Contexto → Decisão → Justificativa → Consequências
4. Atualize esta tabela de índice

### Novo RFC
1. Copie o template de um RFC existente
2. Numere sequencialmente (RFC-004, RFC-005...)
3. Preencha: Resumo → Motivação → Proposta → Critérios de Aceite
4. Submeta como PR para discussão da equipe
5. Atualize esta tabela de índice
