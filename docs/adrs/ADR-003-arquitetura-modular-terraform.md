# ADR-003: Arquitetura Modular do Terraform

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

A infraestrutura do projeto envolve múltiplos recursos AWS interdependentes (VPC, EKS, ALB, API Gateway, IAM, KMS). É necessário decidir como organizar o código Terraform:

1. **Monolito:** todos os recursos em um único diretório com poucos arquivos `.tf`
2. **Módulos locais:** separar recursos em módulos reutilizáveis dentro do repositório
3. **Módulos remotos:** utilizar módulos do Terraform Registry ou repositórios Git externos

## Decisão

Adotar **módulos locais** organizados por responsabilidade, em `infra/modules/`:

```
modules/
├── vpc/           # Rede (VPC, Subnets, NAT, IGW)
├── kms/           # Criptografia
├── iam/           # Roles e políticas
├── eks-cluster/   # Cluster Kubernetes
├── node-group/    # Worker Nodes
├── alb/           # Application Load Balancer
└── api-gateway/   # API Gateway REST
```

Cada módulo segue a convenção: `main.tf`, `variables.tf`, `outputs.tf`.

## Justificativa

- **Separação de responsabilidades:** cada módulo encapsula um domínio específico
- **Reutilização:** módulos podem ser usados em múltiplos ambientes via `tfvars`
- **Testabilidade:** módulos isolados facilitam testes com Terratest
- **Manutenibilidade:** alterações em um componente não impactam diretamente outros
- **Controle total:** módulos locais permitem customização completa para o ambiente FIAP

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Monolito | Difícil manutenção em equipe, alto acoplamento |
| Módulos remotos (Registry) | Menor controle e flexibilidade para requisitos acadêmicos específicos |

## Consequências

### Positivas
- Código organizado e fácil de navegar
- Facilita code review em PRs (cada módulo pode ser revisado isoladamente)
- Simples de adicionar novos componentes (criar novo módulo)

### Negativas
- Módulos locais requerem manutenção pela equipe (vs módulos community mantidos por terceiros)
- Necessidade de definir interfaces claras (`variables.tf` / `outputs.tf`) entre módulos
