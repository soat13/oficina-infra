# ADR-008: Uso de LabRole Existente vs Criação de IAM Roles

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O ambiente AWS da FIAP (AWS Academy) possui restrições de IAM que impedem a criação de novas Roles e políticas. Os alunos recebem uma role pré-configurada chamada **LabRole** com permissões limitadas. O módulo IAM precisa acomodar essa restrição.

## Decisão

Projetar o módulo IAM com **flexibilidade para usar roles existentes**:

- Receber ARNs de roles pré-existentes via variáveis (`existing_cluster_role_arn`, `existing_node_role_arn`)
- Flags condicionais para controlar criação de recursos IAM:
  - `attach_policies = false` — não tenta anexar políticas AWS managed
  - `create_policies = false` — não tenta criar políticas customizadas

## Justificativa

- **Compatibilidade:** funciona tanto com LabRole (FIAP) quanto com roles custom (ambientes produtivos)
- **Flexibilidade:** flags permitem habilitar/desabilitar features IAM conforme permissões disponíveis
- **Princípio de menor privilégio:** módulo não exige mais permissões do que o necessário

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Criar roles novas sempre | Bloqueado pelas restrições do AWS Academy |
| Hardcoded LabRole ARN | Inflexível, não funciona fora do ambiente FIAP |

## Consequências

### Positivas
- Projeto funciona no ambiente restrito da FIAP sem modificações manuais
- Mesma codebase funciona em ambientes com permissões completas
- Documentação clara das permissões necessárias

### Negativas
- LabRole pode ter permissões excessivas (não segue princípio de menor privilégio)
- Dependência de role gerenciada externamente (pode mudar sem aviso)
