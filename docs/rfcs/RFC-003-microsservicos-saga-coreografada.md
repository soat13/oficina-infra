# RFC-003: Divisão de Microsserviços (`ms-oficina`, `ms-auth`, `ms-payment`)

- **Status:** Aprovado
- **Data:** 2026-04-08
- **Autor:** Equipe FIAP SOAT
- **Prioridade:** Alta

## Contexto e Objetivo

A aplicação "Oficina" foi evoluída de monolito para microsserviços em Go para separar responsabilidades de negócio, melhorar reutilização e permitir escala independente. O domínio principal é de ordens de serviço de veículos, com etapas de diagnóstico, aprovação de orçamento, execução de ordens e entrega.

## Decisão Arquitetural

```
Antes:  1 Monolito "Oficina"
Depois: 3 Microsserviços
        ├─ ms-oficina (Core da aplicação)
        ├─ ms-auth (Autenticação & Autorização)
        └─ ms-payment (Processamento de pagamentos)
```

## Justificativas por Serviço

### `ms-auth`
- **Independente do domínio de oficina:** não contém regras de ordem de serviço.
- **Reutilizável:** pode atender mobile app, web app e integrações parceiras.
- **Escala própria:** validação de token ocorre em alto volume e exige scaling separado.

### `ms-payment`
- **Independente do domínio de oficina:** não contém regras de diagnóstico/execução/entrega.
- **Reutilizável:** pode ser aproveitado em outros produtos.
- **Isolamento de risco e compliance:** trata dados sensíveis e integrações financeiras.

### `ms-oficina`
- **Core do negócio:** concentra o ciclo de vida da ordem de serviço.
- **Evento-dirigido:** publica e consome eventos do processo.
- **Específico do domínio:** não é um serviço genérico para outros contextos.

## Coordenação por SAGA Coreografada

A coordenação é orientada a eventos (SNS/SQS), sem coordenador central.

```
Fluxo de ordem de serviço e pagamento:

1) ms-oficina publica eventos do processo (diagnóstico, aprovação, execução)
2) Após execução finalizada, ms-oficina publica "payment-request"
3) ms-payment consome o evento e cria o link de pagamento
4) ms-payment publica "payment-status-change" com os dados do pagamento a cada mudança de status
5) ms-oficina consome cada atualização e atualiza o status da ordem assim como o link de pagamento
```

### Por que Coreografada

- **Baixo acoplamento:** serviços se integram por eventos, não por controle central.
- **Resiliência:** falhas de consumo não param o fluxo; mensagens podem ser reprocessadas.
- **Evolução simples:** novos consumidores podem ser adicionados sem alterar os produtores.
- **Simplicidade operacional:** uso direto dos componentes já existentes (SNS/SQS).

## Benefícios

| Benefício | Impacto |
|---|---|
| **Escalabilidade independente** | Cada serviço escala conforme sua demanda |
| **Deploy autônomo** | Times publicam mudanças sem bloquear os demais |
| **Reutilização** | `ms-auth` e `ms-payment` podem ser usados em outros projetos |
| **Resiliência** | Falha de um serviço não derruba o sistema inteiro |
| **Manutenibilidade** | Domínios bem separados e mais fáceis de evoluir |

## Stack

- **Linguagem:** Go
- **Orquestração:** Kubernetes (EKS)
- **Eventos:** SNS Topics + SQS Queues
- **IaC:** Terraform (módulos existentes)
- **CI/CD:** GitHub Actions

## Critérios de Aceite

- [x] `ms-oficina` deployado com core de ordens de serviço (diagnóstico, execução, entrega)
- [x] `ms-auth` independente e reutilizável
- [x] `ms-payment` independente e reutilizável
- [x] Link de pagamento criado somente após evento de execução finalizada
- [x] `ms-payment` publica atualização de status de pagamento
- [x] `ms-oficina` recebe mensagem a cada atualização de status do pagamento
- [x] Fluxo coordenado por eventos SNS/SQS
- [x] Deploy autônomo de cada serviço

