# ADR-002: Terraform como Ferramenta de Infraestrutura como Código

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O projeto requer uma ferramenta de IaC (Infrastructure as Code) para provisionar e gerenciar todos os recursos AWS de forma reproduzível e versionada. As alternativas consideradas foram:

1. **AWS CloudFormation** — IaC nativa da AWS com templates JSON/YAML
2. **AWS CDK (Cloud Development Kit)** — IaC com linguagens de programação (TypeScript, Python)
3. **Pulumi** — IaC multi-cloud com linguagens de programação
4. **Terraform** — IaC multi-cloud com linguagem declarativa HCL

## Decisão

Adotar o **Terraform** (HashiCorp) como ferramenta de IaC, na versão **1.14.2**.

## Justificativa

- **Declarativo e previsível:** HCL é fácil de ler e auditar, com `plan` antes de `apply`
- **Multi-cloud:** conhecimento transferível para GCP, Azure e outros providers
- **Ecossistema maduro:** Terraform Registry com milhares de módulos e providers mantidos pela comunidade
- **State management:** controle de estado da infraestrutura com suporte a backends remotos (S3)
- **Adoção no mercado:** ferramenta de IaC mais adotada, facilitando contratação e onboarding

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| CloudFormation | Lock-in AWS, sintaxe verbosa (JSON/YAML), sem `plan` nativo equivalente |
| AWS CDK | Abstrai demais, dificulta entendimento do que é provisionado |
| Pulumi | Menor adoção no mercado, escolha menos padrão para equipes DevOps |

## Consequências

### Positivas
- Infraestrutura versionada e auditável no Git
- `terraform plan` permite revisão antes de aplicar mudanças
- Facilidade de criar módulos reutilizáveis
- Portabilidade de conhecimento entre clouds

### Negativas
- Necessidade de gerenciar o state file (mitigado com backend S3)
- Licenciamento BSL da HashiCorp (versões > 1.5.x), alternativa: OpenTofu
- HCL possui limitações para lógica complexa comparado a linguagens de programação
