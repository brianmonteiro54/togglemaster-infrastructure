# 🏗️ ToggleMaster — Infrastructure Developer

> **FIAP — Pós Tech · Tech Challenge — Fase 03**
>
> Repositório central de **Infraestrutura como Código (IaC)** do projeto ToggleMaster.
> Provisiona e gerencia toda a infraestrutura AWS necessária para os 5 microsserviços da plataforma de Feature Flags.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Recursos Provisionados](#-recursos-provisionados)
- [Módulos Terraform](#-módulos-terraform)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Quick Start](#-quick-start)
- [Ambientes](#-ambientes)
- [Pipelines CI/CD](#-pipelines-cicd)
- [Backend Remoto](#-backend-remoto)
- [Segurança](#-segurança)
- [Variáveis](#-variáveis)
- [Outputs](#-outputs)

---

## 🎯 Visão Geral

O **ToggleMaster** é uma plataforma de Feature Flags baseada em microsserviços. Este repositório implementa toda a infraestrutura AWS utilizando **Terraform** com módulos reutilizáveis, seguindo as práticas de:

- **Infrastructure as Code (IaC)** — toda infraestrutura declarada em código
- **GitOps** — mudanças via Pull Requests com revisão e aprovação
- **DevSecOps** — scans de segurança (Checkov, Trivy) integrados ao pipeline
- **Drift Detection** — verificação automática diária (seg-sex) de mudanças manuais
- **Multi-environment** — ambientes `dev` e `prod` isolados via workspaces e tfvars

---

## 🏛️ Arquitetura

```
┌──────────────────────────────────────────────────────────────────────┐
│                          AWS Cloud (us-east-1)                       │
│                                                                      │
│  ┌─────────────────────── VPC 10.0.0.0/20 ───────────────────────┐  │
│  │                                                                │  │
│  │  ┌─── Public Subnets ──┐    ┌──── Private Subnets ────────┐   │  │
│  │  │                      │    │                              │   │  │
│  │  │  ┌──────────────┐   │    │  ┌─────────────────────┐    │   │  │
│  │  │  │  Pritunl VPN │   │    │  │    EKS Cluster       │    │   │  │
│  │  │  │  (EC2 + EIP) │   │    │  │   ┌───────────────┐  │    │   │  │
│  │  │  └──────────────┘   │    │  │   │  Node Group    │  │    │   │  │
│  │  │                      │    │  │   │  (t3.medium)   │  │    │   │  │
│  │  │  ┌──────────────┐   │    │  │   │  2 AZs         │  │    │   │  │
│  │  │  │  NAT Gateway │   │    │  │   └───────────────┘  │    │   │  │
│  │  │  └──────────────┘   │    │  └─────────────────────┘    │   │  │
│  │  └──────────────────────┘    │                              │   │  │
│  │                               │  ┌── Databases ───────────┐ │   │  │
│  │                               │  │ RDS (auth) PostgreSQL  │ │   │  │
│  │                               │  │ RDS (flag) PostgreSQL  │ │   │  │
│  │                               │  │ RDS (targeting) PgSQL  │ │   │  │
│  │                               │  │ ElastiCache (Redis)    │ │   │  │
│  │                               │  └────────────────────────┘ │   │  │
│  │                               └──────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌── Serverless ─────┐  ┌── Container Registry ──────────────────┐  │
│  │ DynamoDB Analytics │  │ ECR: auth / flag / targeting /         │  │
│  │ SQS Events Queue  │  │      evaluation / analytics            │  │
│  └────────────────────┘  └────────────────────────────────────────┘  │
│                                                                      │
│  ┌── State Management ─────────────┐                                 │
│  │ S3 Backend + State Locking      │                                 │
│  └──────────────────────────────────┘                                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Recursos Provisionados

| Categoria | Recurso | Detalhes |
|-----------|---------|----------|
| **Networking** | VPC | `10.0.0.0/20`, 2 AZs, subnets públicas e privadas |
| **Networking** | NAT Gateway | Single NAT (dev) / Multi-AZ (prod) |
| **Compute** | EKS Cluster | Kubernetes 1.34, API privada |
| **Compute** | Node Groups | 2x `t3.medium` (1 por AZ), ON_DEMAND |
| **Compute** | EC2 Pritunl VPN | `t4g.micro` com Elastic IP |
| **Database** | RDS auth-service | PostgreSQL 18.1, `db.t3.micro`, 20GB gp3 |
| **Database** | RDS flag-service | PostgreSQL 18.1, `db.t3.micro`, 20GB gp3 |
| **Database** | RDS targeting-service | PostgreSQL 18.1, `db.t3.micro`, 20GB gp3 |
| **Cache** | ElastiCache Redis | v7.1, `cache.t4g.micro`, TLS habilitado |
| **NoSQL** | DynamoDB | `ToggleMasterAnalytics`, PAY_PER_REQUEST |
| **Mensageria** | SQS | `togglemaster-events`, long-polling |
| **Registry** | ECR (x5) | auth, flag, targeting, evaluation, analytics |

---

## 🧩 Módulos Terraform

Este projeto consome **módulos reutilizáveis** versionados via Git refs:

| Módulo | Repositório | Descrição |
|--------|-------------|-----------|
| `vpc` | [terraform-aws-vpc-network](https://github.com/brianmonteiro54/terraform-aws-vpc-network) | VPC, Subnets, IGW, NAT, Route Tables |
| `eks` | [terraform-aws-eks-platform](https://github.com/brianmonteiro54/terraform-aws-eks-platform) | Cluster EKS, Node Groups, Launch Template, Addons |
| `rds` | [terraform-aws-rds-database](https://github.com/brianmonteiro54/terraform-aws-rds-database) | Instâncias RDS PostgreSQL com SG e Subnet Groups |
| `redis` | [terraform-aws-redis-elasticache](https://github.com/brianmonteiro54/terraform-aws-redis-elasticache) | Cluster ElastiCache Redis com replicação |
| `dynamodb` | [terraform-aws-dynamodb](https://github.com/brianmonteiro54/terraform-aws-dynamodb) | Tabelas DynamoDB com monitoramento |
| `sqs` | [terraform-aws-sqs](https://github.com/brianmonteiro54/terraform-aws-sqs) | Filas SQS com DLQ e dashboards |
| `ecr` | [terraform-aws-ecr](https://github.com/brianmonteiro54/terraform-aws-ecr) | Repositórios ECR com lifecycle policies |
| `ec2` | [terraform-aws-ec2](https://github.com/brianmonteiro54/terraform-aws-ec2) | Instâncias EC2 com SG, EIP e monitoramento |

---

## 📁 Estrutura do Projeto

```
togglemaster-infrastructure-developer/
├── main.tf                  # Provider e versões do Terraform
├── backend.tf               # Configuração do backend S3
├── data.tf                  # Data sources (LabRole IAM)
├── vpc.tf                   # Módulo VPC
├── cluster.tf               # Módulo EKS
├── database.tf              # 3x Módulos RDS (auth, flag, targeting)
├── redis.tf                 # Módulo ElastiCache Redis
├── dynamodb.tf              # Módulo DynamoDB
├── sqs.tf                   # Módulo SQS
├── ecr.tf                   # 5x Módulos ECR
├── ec2_vpn.tf               # Módulo EC2 (Pritunl VPN)
├── ec2_userdata.sh          # Script de inicialização do VPN
├── security_groups.tf       # Security Groups (EKS workers)
├── variables.tf             # Todas as variáveis
├── outputs.tf               # Todos os outputs
├── envs/
│   ├── dev/
│   │   ├── terraform.tfvars # Valores do ambiente dev
│   │   └── backend.hcl      # Backend config (dev state)
│   └── prod/
│       ├── terraform.tfvars # Valores do ambiente prod
│       └── backend.hcl      # Backend config (prod state)
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml     # Pipeline de CI (lint, validate, security, plan)
│       ├── terraform-cd.yml     # Pipeline de CD (plan, apply, verify)
│       └── terraform-destroy.yml # Workflow de destroy controlado
├── .tflint.hcl              # Configuração TFLint
├── .yamllint.yaml           # Configuração YAML Lint
├── .pre-commit-config.yaml  # Pre-commit hooks
└── LICENSE
```

---

## ⚙️ Pré-requisitos

- **Terraform** >= 1.9.0
- **AWS CLI** configurado com credenciais válidas
- **AWS Academy**: LabRole existente (o Terraform **não** cria roles IAM)
- **Bucket S3** `togglemaster-terraform` para backend remoto

---

## 🚀 Quick Start

```bash
# 1. Clone o repositório
git clone https://github.com/brianmonteiro54/togglemaster-infrastructure-developer.git
cd togglemaster-infrastructure-developer

# 2. Inicialize com backend do ambiente desejado
terraform init -backend-config="envs/dev/backend.hcl"

# 3. Revise o plano de execução
terraform plan -var-file="envs/dev/terraform.tfvars"

# 4. Aplique a infraestrutura
terraform apply -var-file="envs/dev/terraform.tfvars"

# 5. Configure o kubectl
$(terraform output -raw kubeconfig_command)
```

---

## 🌍 Ambientes

| Ambiente | Branch | State Path | NAT | Deletion Protection |
|----------|--------|------------|-----|---------------------|
| **dev** | `developer` | `s3://togglemaster-terraform/dev/terraform.tfstate` | Single | Desabilitado |
| **prod** | `main` | `s3://togglemaster-terraform/prd/terraform.tfstate` | Multi-AZ | Habilitado |

---

## 🔄 Pipelines CI/CD

### CI (terraform-ci.yml)

Executado em **Pull Requests** e **Push** nas branches `main` e `developer`:

| Job | Descrição | Bloqueante |
|-----|-----------|------------|
| **Lint & Format** | `terraform fmt` + TFLint | ✅ Sim |
| **Validate** | `terraform validate` | ⚠️ Warning |
| **Security Scanning** | Checkov + Trivy IaC | ⚠️ Warning |
| **Plan Preview** | `terraform plan` por ambiente | Informativo |
| **Terraform Docs** | Auto-geração de documentação | Não |
| **CI Gate** | Portão final consolidado | ✅ Sim |

### CD (terraform-cd.yml)

Disparado automaticamente após CI bem-sucedido:

| Job | Descrição |
|-----|-----------|
| **Resolve Environment** | Mapeia branch → ambiente (dev/prod) |
| **Plan** | Gera plano de execução com artefato |
| **Drift Alert** | Detecção de drift (schedule seg-sex 06:00 UTC) |
| **Apply** | Aplica mudanças (requer aprovação via Environment Gate) |
| **Verify** | Plan pós-apply para confirmar state limpo |
| **Notify Failure** | Notificação em caso de falha |

### Destroy (terraform-destroy.yml)

Workflow manual com múltiplas camadas de segurança: confirmação dupla, justificativa obrigatória, backup de state, Environment Gate.

---

## 🔒 Backend Remoto

```hcl
# envs/dev/backend.hcl
bucket       = "togglemaster-terraform"
key          = "dev/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

O `terraform.tfstate` **nunca** fica local. Estado armazenado em S3 com criptografia e locking via `use_lockfile`.

---

## 🛡️ Segurança

- **IAM**: Utiliza `LabRole` existente (compatível com AWS Academy)
- **Encryption at Rest**: RDS, Redis, DynamoDB e EBS com criptografia habilitada
- **TLS**: Redis com transit encryption habilitado
- **IMDSv2**: Obrigatório em todas as instâncias EC2/EKS
- **Security Groups**: Princípio do menor privilégio com regras específicas
- **ECR**: Imagens imutáveis com lifecycle policies
- **Secrets**: Senhas RDS gerenciadas pelo AWS Secrets Manager (`manage_master_user_password = true`)
- **Scanning**: Checkov + Trivy integrados ao CI
- **Pre-commit**: Hooks locais para segurança antes do push

---

## 📤 Outputs

| Output | Descrição |
|--------|-----------|
| `vpc_id` | ID da VPC |
| `cluster_name` | Nome do cluster EKS |
| `cluster_endpoint` | Endpoint da API do EKS |
| `kubeconfig_command` | Comando para configurar kubectl |
| `auth_service_endpoint` | Endpoint RDS do auth-service |
| `flag_service_endpoint` | Endpoint RDS do flag-service |
| `targeting_service_endpoint` | Endpoint RDS do targeting-service |
| `redis_primary_endpoint` | Endpoint primário do Redis |
| `sqs_queue_url` | URL da fila SQS |
| `dynamodb_table_name` | Nome da tabela DynamoDB |
| `vpn_ec2_public_ip` | IP público do VPN |

---

## 📖 Documentação Auto-gerada

A seção abaixo é **automaticamente populada** pelo [terraform-docs](https://terraform-docs.io/) via GitHub Actions (`terraform-docs/gh-actions@v1.3.0`) a cada Pull Request. O job injeta automaticamente a documentação de **Requirements**, **Providers**, **Modules**, **Resources**, **Inputs** e **Outputs** entre os marcadores abaixo.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

> **FIAP — Pós Tech · DevOps & Cloud Computing**
> Tech Challenge — Fase 03
