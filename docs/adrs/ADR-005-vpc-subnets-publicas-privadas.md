# ADR-005: VPC com Subnets Públicas e Privadas

- **Status:** Aceito
- **Data:** 2026-03-11
- **Decisores:** Equipe FIAP SOAT

## Contexto

O cluster EKS e seus componentes precisam de uma infraestrutura de rede isolada. É necessário definir a topologia de rede:

1. **Subnets apenas públicas** — todos os recursos com IP público
2. **Subnets apenas privadas** — acesso externo via VPN/bastion
3. **Misto: públicas + privadas** — separação entre recursos expostos e internos

## Decisão

Criar uma **VPC com CIDR 10.0.0.0/16** contendo:
- **2 subnets públicas** (uma por AZ) — para NAT Gateways e Load Balancers
- **2 subnets privadas** (uma por AZ) — para EKS Nodes e workloads
- **Internet Gateway** — conectividade externa para subnets públicas
- **2 NAT Gateways** (um por AZ) — saída de tráfego para subnets privadas
- **Route Tables** — roteamento automático entre subnets

## Justificativa

- **Segurança:** worker nodes do EKS em subnets privadas, sem IP público, reduzem a superfície de ataque
- **Alta disponibilidade:** 2 AZs com NAT Gateways redundantes evitam SPOF
- **Separação de responsabilidades:** Load Balancers nas subnets públicas, workloads nas privadas
- **Best practice AWS:** topologia recomendada pela AWS para workloads EKS

## Alternativas Descartadas

| Alternativa | Motivo da rejeição |
|---|---|
| Apenas públicas | Exposição desnecessária dos nodes, contrário a best practices |
| Apenas privadas | Complexidade para acesso inicial (VPN/bastion necessários) |

## Consequências

### Positivas
- Nodes EKS protegidos sem acesso direto da internet
- ALB nas subnets públicas distribui tráfego para nodes privados
- NAT Gateways permitem que nodes acessem internet (pull de imagens, updates)

### Negativas
- **Custo dos NAT Gateways:** ~$32/mês por NAT Gateway × 2 = ~$64/mês (ver RFC-007 para otimização)
- Complexidade adicional no roteamento e troubleshooting de rede
