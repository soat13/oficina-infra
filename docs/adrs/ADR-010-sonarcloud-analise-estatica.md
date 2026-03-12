# ADR-010: SonarCloud como Ferramenta de Análise Estática

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O projeto necessita de uma ferramenta de análise de qualidade e segurança de código integrada ao pipeline de CI/CD. As opções:

1. **SonarQube (self-hosted)** — análise completa, requer servidor dedicado
2. **SonarCloud (SaaS)** — versão cloud do SonarQube, free para projetos open-source
3. **CodeQL (GitHub)** — análise de segurança nativa do GitHub
4. **Snyk** — foco em vulnerabilidades e dependências

## Decisão

Adotar **SonarCloud** como quality gate obrigatório no pipeline, executado antes do Terraform plan.

## Justificativa

- **Free para open-source:** sem custo para repositórios públicos
- **Quality Gate:** bloqueia merge de PRs com problemas de qualidade
- **Cobertura ampla:** bugs, vulnerabilidades, code smells, duplicação, cobertura de testes
- **Integração GitHub:** feedback direto nas PRs com annotations
- **Sem infraestrutura:** SaaS gerenciado, sem necessidade de servidor

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| SonarQube self-hosted | Requer infraestrutura e manutenção |
| CodeQL | Foco apenas em segurança, sem análise de qualidade |
| Snyk | Foco em dependências, menos abrangente para código IaC |

## Consequências

### Positivas
- Qualidade de código garantida por gate automático
- Identificação precoce de vulnerabilidades
- Dashboard de métricas de qualidade ao longo do tempo

### Negativas
- Dependência de serviço externo (SonarCloud)
- Tempo adicional no pipeline (~1-2 minutos por execução)
