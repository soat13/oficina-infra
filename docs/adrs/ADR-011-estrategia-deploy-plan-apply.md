# ADR-011: Estratégia de Deploy com Terraform Plan → Apply Separados

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O Terraform pode ser executado de duas formas no CI/CD:

1. **Plan + Apply em um único job** — mais simples, mas sem revisão intermediária
2. **Plan e Apply em jobs separados** — plan gera artefato, apply consome o artefato
3. **Plan na PR, Apply no merge** — plan mostra diff na PR, apply apenas na main

## Decisão

Separar o pipeline em **jobs distintos** com passagem de artefato:

1. **`terraform-plan`** — executa `fmt`, `init`, `validate`, `plan` e faz upload do plano como artefato
2. **`terraform-apply`** — faz download do plano e aplica com `--auto-approve`
3. **`terraform-apply`** só executa na branch `main` (`if: github.ref == 'refs/heads/main'`)

## Justificativa

- **Previsibilidade:** o artefato `tfplan` garante que exatamente o que foi planejado será aplicado
- **Segurança:** sem risco de drift entre plan e apply (plano binário)
- **Revisão:** plan roda em PRs, permitindo code review das mudanças de infra
- **Auditoria:** artefato do plan fica retido por 5 dias no GitHub

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Plan + Apply em único job | Sem oportunidade de revisão antes do apply |
| Apply manual via CLI | Não escalável, propenso a erros humanos |

## Consequências

### Positivas
- Mudanças de infraestrutura revisáveis antes de aplicar
- Pipeline rastreável e auditável
- Apply automático somente na main (proteção de branches)

### Negativas
- Pipeline mais demorado (dois jobs sequenciais)
- Sem aprovação manual explícita antes do apply (ver RFC-009)
