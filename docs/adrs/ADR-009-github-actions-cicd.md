# ADR-009: GitHub Actions como Plataforma de CI/CD

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O projeto precisa de um pipeline de CI/CD automatizado para validar, planejar e aplicar mudanças de infraestrutura. As opções consideradas:

1. **Jenkins** — CI/CD self-hosted, altamente configurável
2. **GitLab CI** — CI/CD integrado ao GitLab
3. **AWS CodePipeline** — CI/CD nativo AWS
4. **GitHub Actions** — CI/CD integrado ao GitHub

## Decisão

Adotar **GitHub Actions** como plataforma de CI/CD, com o pipeline definido em `.github/workflows/ci-cd.yml`, composto por 4 jobs sequenciais:

1. **sonar-scan** — Análise de qualidade com SonarCloud
2. **terraform-plan** — Formatação, validação e planejamento
3. **terraform-apply** — Aplicação da infraestrutura (apenas `main`)
4. **datadog-deploy** — Deploy do agente Datadog via Helm

## Justificativa

- **Integração nativa:** repositório já está no GitHub, sem necessidade de ferramenta externa
- **Custo:** free tier generoso (2.000 min/mês para repositórios privados)
- **Ecossistema:** marketplace com milhares de actions reutilizáveis
- **Simplicidade:** configuração via YAML no próprio repositório
- **Concorrência gerenciada:** `concurrency` groups impedem execuções paralelas conflitantes

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Jenkins | Requer infraestrutura dedicada, manutenção de servidor |
| GitLab CI | Repositório no GitHub, migração desnecessária |
| AWS CodePipeline | Lock-in AWS, integração menos natural com GitHub |

## Consequências

### Positivas
- Pipeline versionado junto com o código (GitOps)
- Runners gerenciados pelo GitHub (sem infraestrutura adicional)
- Visibilidade de status nas PRs e commits
- Controle de concorrência nativo (`cancel-in-progress`)

### Negativas
- Runners públicos compartilhados (possíveis filas em horários de pico)
- Secrets armazenados no GitHub (vs AWS Secrets Manager)
- Dependência do GitHub como plataforma (risco de vendor lock-in leve)
