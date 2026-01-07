# Oficina Infra

## Visão Geral

Este projeto implementa uma arquitetura completa e moderna na AWS utilizando **Terraform** para provisionamento de infraestrutura como código (IaC), **Amazon EKS** (Elastic Kubernetes Service) para orquestração de containers, **RDS PostgreSQL** como banco de dados gerenciado, e um pipeline **CI/CD** totalmente automatizado com **GitHub Actions**.

A solução foi desenvolvida seguindo as melhores práticas de DevOps, segurança e escalabilidade, com análise contínua de código via **SonarCloud** e deploy automatizado em múltiplos ambientes (dev, hom, prod).

## Diagrama da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (us-east-1)                                 │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                                VPC                                        │  │
│  │                                                                           │  │
│  │   ┌─────────────────────────┐       ┌─────────────────────────┐           │  │
│  │   │  Availability Zone A    │       │  Availability Zone B    │           │  │
│  │   │                         │       │                         │           │  │
│  │   │  ┌──────────────────┐   │       │   ┌──────────────────┐  │           │  │
│  │   │  │ Public Subnet    │   │       │   │ Public Subnet    │  │           │  │
│  │   │  │  ┌────────────┐  │   │       │   │  ┌────────────┐  │  │           │  │
│  │   │  │  │ NAT Gateway│  │   │       │   │  │ NAT Gateway│  │  │           │  │
│  │   │  │  └─────┬──────┘  │   │       │   │  └─────┬──────┘  │  │           │  │
│  │   │  └────────┼─────────┘   │       │   └────────┼─────────┘  │           │  │
│  │   │           │             │       │            │            │           │  │
│  │   │  ┌────────▼─────────┐   │       │   ┌────────▼─────────┐  │           │  │
│  │   │  │ Private Subnet   │   │       │   │ Private Subnet   │  │           │  │
│  │   │  │ ┌──────────────┐ │   │       │   │ ┌──────────────┐ │  │           │  │
│  │   │  │ │  EKS Nodes   │ │   │       │   │ │  EKS Nodes   │ │  │           │  │
│  │   │  │ │ (Auto Scaling│ │   │       │   │ │ (Auto Scaling│ │  │           │  │
│  │   │  │ │   Group)     │ │   │       │   │ │   Group)     │ │  │           │  │
│  │   │  │ └──────────────┘ │   │       │   │ └──────────────┘ │  │           │  │
│  │   │  │                  │   │       │   │                  │  │           │  │
│  │   │  │ ┌──────────────┐ │   │       │   │                  │  │           │  │
│  │   │  │ │     RDS      │ │   │       │   │                  │  │           │  │
│  │   │  │ │  PostgreSQL  │ │   │       │   │                  │  │           │  │
│  │   │  │ │              │ │   │       │   │                  │  │           │  │
│  │   │  │ └──────────────┘ │   │       │   │                  │  │           │  │
│  │   │  └──────────────────┘   │       │   └──────────────────┘  │           │  │
│  │   └─────────────────────────┘       └─────────────────────────┘           │  │
│  │                                                                           │  │
│  │   Internet Gateway ◄────────────────────► Public Subnets                  │  │
│  │                                                                           │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                   EKS Control Plane (Gerenciado AWS)                      │  │
│  │  • API Server  • Scheduler  • Controller Manager  • etcd                  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐       │
│  │   KMS Key        │  │  IAM Roles       │  │  Security Groups         │       │
│  │  (Criptografia)  │  │  (LabRole)       │  │  (Cluster, Node, RDS)    │       │
│  └──────────────────┘  └──────────────────┘  └──────────────────────────┘       │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  CloudWatch Logs  │  Amazon ECR (Container Registry)                      │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │
                                      │ CI/CD
                                      │
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            GitHub Actions Pipeline                              │
│                                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   SonarCloud │───▶│  Terraform   │──▶│  Terraform   │──▶│  Kubernetes  │   │
│  │     Scan     │    │     Plan     │    │     Apply    │    │    Deploy    │   │
│  └──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘   │
│   • Security           • Validate           • Provisiona        • Namespace     │
│   • Code Quality       • Format             • Infraestrutura    • Deployment    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Resources (namespace: fiap)                   │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                          Deployment: oficina                              │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            ┌──────────┐         │  │
│  │  │   Pod    │  │   Pod    │  │   Pod    │     ...    │   Pod    │         │  │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘            └────┬─────┘         │  │
│  │       │             │             │                       │               │  │
│  │       └─────────────┴─────────────┴───────────────────────┘               │  │
│  │                              │                                            │  │
│  │                    ┌─────────▼─────────┐                                  │  │
│  │                    │  Service: ext-lb  │                                  │  │
│  │                    │  (LoadBalancer)   │                                  │  │
│  │                    │                   │                                  │  │
│  │                    └─────────┬─────────┘                                  │  │
│  │                              │                                            │  │
│  └──────────────────────────────┼────────────────────────────────────────────┘  │
│                                 │                                               │
│  ┌──────────────────────────────▼────────────────────────────────────────────┐  │
│  │                    AWS Elastic Load Balancer                              │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                 │                                               │
│  ┌──────────────────────────────▼────────────────────────────────────────────┐  │
│  │              HPA (Horizontal Pod Autoscaler)                              │  │
│  │              Escala automaticamente baseado em CPU                        │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │   Internet    │
                              │    Users      │
                              └───────────────┘
```

## Infraestrutura

### Pré-requisitos

- **Terraform**: v1.14.2+
- **AWS CLI**: v2.0+
- **kubectl**: v1.28+
- **Conta AWS** com permissões adequadas
- **AWS Credentials** configuradas (via `aws configure` ou variáveis de ambiente)

### Arquitetura de Módulos

#### 1. **VPC Module** (`modules/vpc`)
Provê toda a infraestrutura de rede isolada:
- **VPC** com CIDR 10.0.0.0/16
- **2 Subnets públicas** (uma por AZ) - para NAT Gateways e Load Balancers
- **2 Subnets privadas** (uma por AZ) - para EKS Nodes e RDS
- **Internet Gateway** - conectividade externa
- **2 NAT Gateways** - alta disponibilidade para saída de tráfego das subnets privadas
- **Route Tables** - roteamento configurado automaticamente

#### 2. **KMS Module** (`modules/kms`)
Gerencia criptografia de dados sensíveis:
- Chave KMS para criptografia de **secrets do EKS**
- Chave KMS para criptografia do **RDS at-rest**
- Alias `{cluster-name}-eks` para fácil identificação
- Janela de deleção configurável (padrão: 30 dias)

#### 3. **IAM Module** (`modules/iam`)
Gerenciamento de permissões e roles:
- Utiliza **LabRole** existente para cluster EKS e worker nodes
- Suporte para anexar políticas AWS gerenciadas (quando permitido)
- Políticas customizadas para casos específicos
- Princípio de menor privilégio aplicado

#### 4. **EKS Cluster Module** (`modules/eks-cluster`)
Cluster Kubernetes gerenciado:
- **EKS Control Plane** com Kubernetes 1.33
- **Security Groups** para cluster e comunicação com nodes
- **CloudWatch Logs** para API, Audit, Authenticator, Controller Manager, Scheduler
- **Endpoint público** com CIDRs configuráveis
- **Criptografia de secrets** habilitada com KMS
- Retenção de logs configurável (padrão: 7 dias)

#### 5. **Node Group Module** (`modules/node-group`)
Worker nodes gerenciados:
- **Instâncias**: t3.medium (configurável)
- **AMI**: Amazon Linux 2023 (AL2023_x86_64_STANDARD)
- **Capacity Type**: ON_DEMAND (ou SPOT para economia)
- **Auto Scaling**: 1 (min) → 2 (desired) → 4 (max) nodes
- **Disk**: 20 GB gp3 por node
- **Labels Kubernetes** customizados para workload placement
- SSH opcional via EC2 Key Pair

#### 6. **RDS PostgreSQL Module** (`modules/rds-postgres`)
Banco de dados gerenciado:
- **Engine**: PostgreSQL 16.10
- **Instance**: db.t3.micro (single-AZ para dev)
- **Storage**: 20 GB gp3 com auto-scaling até 100 GB
- **Backup**: 5 dias de retenção automática
- **Criptografia**: KMS at-rest e SSL em trânsito
- **Subnet privada**: Sem acesso público direto
- **CloudWatch Logs**: Exportação automática de logs do PostgreSQL
- **Manutenção**: Segunda-feira 04:00-05:00 UTC

### Configuração por Ambiente

A infraestrutura suporta múltiplos ambientes através de arquivos de variáveis em `infra/inventories/{env}/terraform.tfvars`:

| Ambiente | Diretório | Descrição | Recursos |
|----------|-----------|-----------|----------|
| **dev** | `inventories/dev/` | Desenvolvimento | Recursos mínimos, deletion_protection=false |
| **hom** | `inventories/hom/` | Homologação | Configuração similar a produção |
| **prod** | `inventories/prod/` | Produção | Alta disponibilidade, backups, proteção |

### Comandos Terraform

```bash
# Navegar para o diretório de infraestrutura
cd infra/

# Inicializar o Terraform
terraform init

# Validar a configuração
terraform validate

# Planejar mudanças (dev)
terraform plan -var-file=inventories/dev/terraform.tfvars

# Aplicar infraestrutura (dev)
terraform apply -var-file=inventories/dev/terraform.tfvars

# Ver outputs da infraestrutura
terraform output

# Destruir infraestrutura (cuidado!)
terraform destroy -var-file=inventories/dev/terraform.tfvars
```

## Estrutura do Projeto

```
fase-2-oficina/
│
├── .github/                          # Automação e CI/CD
│   └── workflows/
│       └── ci-cd.yml                 # Pipeline: SonarCloud → Terraform → K8s
│
├── infra/                            # Infraestrutura como Código (Terraform)
│   ├── modules/                      # Módulos reutilizáveis
│   │   ├── vpc/                      # Rede (VPC, Subnets, NAT, IGW)
│   │   ├── kms/                      # Chaves de criptografia
│   │   ├── iam/                      # Roles e políticas IAM
│   │   ├── eks-cluster/              # Cluster Kubernetes
│   │   ├── node-group/               # Worker Nodes
│   │   └── rds-postgres/             # Banco de dados PostgreSQL
│   │
│   ├── inventories/                  # Configurações por ambiente
│   │   ├── dev/                      # Desenvolvimento
│   │   ├── hom/                      # Homologação
│   │   └── prod/                     # Produção
│   │
│   ├── main.tf                       # Orquestração dos módulos
│   ├── variables.tf                  # Variáveis
│   ├── outputs.tf                    # Outputs
│   ├── provider.tf                   # Provider AWS
│   └── backend.tf                    # Backend S3
│
├── k8s/                              # Manifestos Kubernetes
│   ├── app/
│   │   ├── app.yaml                  # Deployment da aplicação
│   │   ├── configmap.yaml            # ConfigMap
│   │   ├── hpa.yaml                  # Horizontal Pod Autoscaler
│   │   ├── namespace.yaml            # Namespace
│   │   ├── secrets.yaml              # Secrets
│   │   ├── serviceaccount.yaml       # ServiceAccount
│   │   └── services.yaml             # LoadBalancer Service
│   └── scripts/
│       └── migrations/               # Migração do banco de dados
│
└── sonar-project.properties          # Configuração do SonarCloud
```

## Kubernetes (K8S)

### Recursos Kubernetes

#### **Namespace: `fiap`**
Isola os recursos da aplicação em um namespace dedicado.

#### **ConfigMap: `app-config`**
Configurações não-sensíveis da aplicação:
```yaml
MIGRATIONS_DIR: "scripts/db/migrations"
PORT: "8080"
```

#### **Secret: `app-sc`**
Credenciais sensíveis (criadas via CI/CD):
- `JWT_SECRET`: Secret para tokens JWT
- `POSTGRES_USER`: Usuário do banco
- `POSTGRES_PASSWORD`: Senha do banco
- `POSTGRES_DB`: Nome do database
- `PG_DSN`: Connection string completa do PostgreSQL

#### **Deployment: `oficina`**
Especificações do deployment:
- **Replicas**: 2 (mínimo, escalável via HPA)
- **Image**: Utiliza imagem gerada da camada de aplicação que está no ECR
- **Port**: 8080

#### **Service: `ext-lb`**
LoadBalancer para expor a aplicação:
- **Type**: LoadBalancer (AWS ELB)
- **Port**: 3000 (externo) → 8080 (container)
- **Protocol**: TCP
- **Selector**: `app: oficina`

#### **HPA (Horizontal Pod Autoscaler)**
Auto-scaling baseado em métricas:
- **Min Replicas**: 1
- **Max Replicas**: 10
- **Target CPU**: 50% de utilização
- **Scale Up**: Rápido (15s, até 4 pods por vez)
- **Scale Down**: Gradual (30s de estabilização)

### Acesso à Aplicação

Após o deploy, obtenha a URL do LoadBalancer através da pipe ou pelo Kubernetes

A aplicação estará disponível em: `http://<LOAD_BALANCER_DNS>:3000`

## Escalabilidade

### Horizontal Pod Autoscaling (HPA)

A aplicação escala automaticamente baseada em CPU:
- **Mínimo**: 1 replica
- **Máximo**: 10 replicas
- **Target**: 50% CPU

### Node Autoscaling (Cluster Autoscaler)

Para habilitar o Cluster Autoscaler:

1. Deploy do Cluster Autoscaler no EKS
2. Configurar IAM policies adequadas
3. Ajustar min/max size do node group

### Database Scaling

- **Storage**: Auto-scaling de 20 GB até 100 GB
- **Read Replicas**: Podem ser adicionadas para leitura
- **Vertical Scaling**: Alterar `rds_instance_class` no tfvars

## CI/CD Pipeline

### Pipeline GitHub Actions

O pipeline é acionado em:
- **Push** na branch `main`
- **Pull Requests** em qualquer branch
- **Repository Dispatch** (tipo: `deploy-application`)

### Jobs do Pipeline

#### **1. sonar-scan**
Análise de qualidade e segurança do código:
- **Ferramenta**: SonarCloud
- **Configuração**: `sonar-project.properties`

#### **2. terraform-plan**
Planejamento da infraestrutura:
- **Dependência**: sonar-scan
- **Passos**:
  1. Checkout do código
  2. Setup do Terraform (v1.14.2)
  3. Configuração de credenciais AWS
  4. `terraform fmt -check` (validação de formatação)
  5. `terraform init` (inicialização)
  6. `terraform validate` (validação sintática)
  7. `terraform plan` (planejamento)
  8. Upload do plano como artefato

#### **3. terraform-apply**
Aplicação da infraestrutura:
- **Dependência**: terraform-plan
- **Condição**: Apenas na branch `main`
- **Environment**: dev (ou conforme input)
- **Passos**:
  1. Download do plano gerado
  2. `terraform apply` (aplicação automática)
  3. Captura de outputs (cluster name, endpoint, RDS info)
  4. Upload dos outputs como artefato

#### **4. k8s-deploy**
Deploy no Kubernetes:
- **Dependência**: terraform-apply
- **Condição**: Apenas na branch `main`
- **Passos**:
  1. Configuração do kubeconfig
  2. Criação do namespace e recursos base
  3. Download dos outputs do Terraform
  4. Criação/atualização de Secrets
  5. Deploy da aplicação (`kubectl apply -f k8s/app/`)
  6. Restart do deployment
  7. Aguarda LoadBalancer e exibe URL
