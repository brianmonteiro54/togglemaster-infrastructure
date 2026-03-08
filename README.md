# 🏗️ ToggleMaster — Infrastructure Developer

> **FIAP — Pós Tech · Tech Challenge — Fase 03**
>
> Repositório central de **Infraestrutura como Código (IaC)** do projeto ToggleMaster.
> Provisiona e gerencia toda a infraestrutura AWS necessária para os 5 microsserviços da plataforma de Feature Flags.

---

## ⚠️ Nota sobre credenciais

Este projeto utiliza AWS Academy, que impõe restrições na criação de
IAM Roles e Identity Providers. Por isso, as credenciais AWS são
passadas via secrets do GitHub Actions e injetadas na EC2 de bootstrap.

Em um ambiente de produção real, a abordagem correta seria:
- **GitHub Actions → AWS**: OIDC Federation (sem access keys)
- **EC2 Bootstrap → EKS**: IAM Instance Profile com role dedicada
- **Pods → AWS**: IRSA (IAM Roles for Service Accounts)

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
┌──────────────────────────────────────────────────────────────────────────┐
│                         AWS Cloud (us-east-1)                            │
│                                                                          │
│  ┌────────────────────────── VPC 10.0.0.0/20 ─────────────────────────┐  │
│  │                                                                    │  │
│  │  ┌── Public Subnets ───────┐    ┌── Private Subnets ────────────┐  │  │
│  │  │                         │    │                               │  │  │
│  │  │  ┌───────────────────┐  │    │  ┌────────────────────────┐   │  │  │
│  │  │  │   Pritunl VPN     │  │    │  │     EKS Cluster        │   │  │  │
│  │  │  │   (EC2 + EIP)     │  │    │  │  ┌──────────────────┐  │   │  │  │
│  │  │  └───────────────────┘  │    │  │  │   Node Group     │  │   │  │  │
│  │  │                         │    │  │  │   (t3.medium)    │  │   │  │  │
│  │  │  ┌───────────────────┐  │    │  │  │   2 AZs          │  │   │  │  │
│  │  │  │   NAT Gateway     │  │    │  │  └──────────────────┘  │   │  │  │
│  │  │  └───────────────────┘  │    │  └────────────────────────┘   │  │  │
│  │  └─────────────────────────┘    │                               │  │  │
│  │                                 │  ┌── Databases ────────────┐  │  │  │
│  │                                 │  │  RDS (auth) PostgreSQL  │  │  │  │
│  │                                 │  │  RDS (flag) PostgreSQL  │  │  │  │
│  │                                 │  │  RDS (targeting) PgSQL  │  │  │  │
│  │                                 │  │  ElastiCache (Redis)    │  │  │  │
│  │                                 │  └─────────────────────────┘  │  │  │
│  │                                 └───────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌── Serverless ──────────┐  ┌── Container Registry ──────────────────┐  │
│  │  DynamoDB Analytics    │  │  ECR: auth / flag / targeting /        │  │
│  │  SQS Events Queue      │  │       evaluation / analytics           │  │
│  └────────────────────────┘  └────────────────────────────────────────┘  │
│                                                                          │
│  ┌── State Management ──────────────┐                                    │
│  │  S3 Backend + State Locking      │                                    │
│  └──────────────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────────────┘
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
| `bootstrap` | [terraform-aws-eks-bootstrap](https://github.com/brianmonteiro54/terraform-aws-eks-bootstrap) | Instâncias EC2 temporária dentro da VPC do EKS para executar o setup inicial do cluster |

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.31 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.32.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb_analytics"></a> [dynamodb\_analytics](#module\_dynamodb\_analytics) | github.com/brianmonteiro54/terraform-aws-dynamodb//modules/dynamodb | 8a55060136580d55f3953de4116ce485ca9e1b11 |
| <a name="module_ec2_bootstrap"></a> [ec2\_bootstrap](#module\_ec2\_bootstrap) | github.com/brianmonteiro54/terraform-aws-eks-bootstrap//modules/bootstrap | 7e2ddeb6630a62b39808554218a10cd80dcaeb46 |
| <a name="module_ecr_analytics_service"></a> [ecr\_analytics\_service](#module\_ecr\_analytics\_service) | github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr | 2c4973a14fc5d908e6d9c534d46a453a18d29206 |
| <a name="module_ecr_auth_service"></a> [ecr\_auth\_service](#module\_ecr\_auth\_service) | github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr | 2c4973a14fc5d908e6d9c534d46a453a18d29206 |
| <a name="module_ecr_evaluation_service"></a> [ecr\_evaluation\_service](#module\_ecr\_evaluation\_service) | github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr | 2c4973a14fc5d908e6d9c534d46a453a18d29206 |
| <a name="module_ecr_flag_service"></a> [ecr\_flag\_service](#module\_ecr\_flag\_service) | github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr | 2c4973a14fc5d908e6d9c534d46a453a18d29206 |
| <a name="module_ecr_targeting_service"></a> [ecr\_targeting\_service](#module\_ecr\_targeting\_service) | github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr | 2c4973a14fc5d908e6d9c534d46a453a18d29206 |
| <a name="module_eks"></a> [eks](#module\_eks) | github.com/brianmonteiro54/terraform-aws-eks-platform//modules/eks | 116e4fa01cd755dbe0516249c6d916b52274ba6b |
| <a name="module_pritunl_vpn"></a> [pritunl\_vpn](#module\_pritunl\_vpn) | github.com/brianmonteiro54/terraform-aws-ec2//modules/ec2 | 17c9a7d61d695ae4fa4033e091c2744377e583ac |
| <a name="module_rds_auth_service"></a> [rds\_auth\_service](#module\_rds\_auth\_service) | github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds | d4a0e3993842e0876d3d918573ff895145befa2a |
| <a name="module_rds_flag_service"></a> [rds\_flag\_service](#module\_rds\_flag\_service) | github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds | d4a0e3993842e0876d3d918573ff895145befa2a |
| <a name="module_rds_targeting_service"></a> [rds\_targeting\_service](#module\_rds\_targeting\_service) | github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds | d4a0e3993842e0876d3d918573ff895145befa2a |
| <a name="module_redis"></a> [redis](#module\_redis) | github.com/brianmonteiro54/terraform-aws-redis-elasticache//modules/redis | f0f4e72d72b8f44d1ffec64df7fb096cf1de8ba8 |
| <a name="module_sqs_events"></a> [sqs\_events](#module\_sqs\_events) | github.com/brianmonteiro54/terraform-aws-sqs//modules/sqs | 474eeb54ac7af491c1d921a6d78746cf920647c2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/brianmonteiro54/terraform-aws-vpc-network//modules/vpc | 1185cd978b63dae90bac2097c666f3fe45e64f61 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.eks_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.eks_workers_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.eks_workers_from_pritunl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.eks_workers_from_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.eks_workers_from_vpc_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_role.lab_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | IAM access entries for the EKS cluster. | `any` | n/a | yes |
| <a name="input_addons"></a> [addons](#input\_addons) | Map of EKS add-ons and their configurations. | `any` | n/a | yes |
| <a name="input_all_protocols"></a> [all\_protocols](#input\_all\_protocols) | Protocol identifier representing all protocols (e.g., -1). | `string` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID used for the EC2 instance. | `string` | n/a | yes |
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Redis AUTH token (min 16 chars, max 128 chars) | `string` | `null` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | Authentication mode for the EKS cluster. | `string` | n/a | yes |
| <a name="input_aws_access_key_id"></a> [aws\_access\_key\_id](#input\_aws\_access\_key\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_secret_access_key"></a> [aws\_secret\_access\_key](#input\_aws\_secret\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_aws_session_token"></a> [aws\_session\_token](#input\_aws\_session\_token) | n/a | `string` | `""` | no |
| <a name="input_bootstrap_cluster_creator_admin_permissions"></a> [bootstrap\_cluster\_creator\_admin\_permissions](#input\_bootstrap\_cluster\_creator\_admin\_permissions) | Grant cluster creator admin permissions during bootstrap. | `bool` | n/a | yes |
| <a name="input_cluster_kms_key_arn"></a> [cluster\_kms\_key\_arn](#input\_cluster\_kms\_key\_arn) | Existing KMS key ARN for EKS secrets encryption. Required when enable\_secrets\_encryption=true and create\_kms\_key=false. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Additional tags applied to the EKS cluster. | `map(string)` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the EKS cluster. | `string` | n/a | yes |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Create and associate Elastic IP | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Create a customer-managed KMS key (CMK) when encryption is enabled and kms\_key\_arn is null. | `bool` | `false` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage size in GB. | `number` | n/a | yes |
| <a name="input_db_backup_retention_period"></a> [db\_backup\_retention\_period](#input\_db\_backup\_retention\_period) | Number of days to retain automated backups. | `number` | n/a | yes |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | Enable deletion protection for the RDS instance. | `bool` | n/a | yes |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Database engine type (e.g., postgres, mysql). | `string` | n/a | yes |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Version of the database engine. | `string` | n/a | yes |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | Unique identifier for the Auth RDS instance. | `string` | n/a | yes |
| <a name="input_db_identifier_flag"></a> [db\_identifier\_flag](#input\_db\_identifier\_flag) | Unique identifier for the Flag RDS instance. | `string` | n/a | yes |
| <a name="input_db_identifier_targeting"></a> [db\_identifier\_targeting](#input\_db\_identifier\_targeting) | Unique identifier for the Targeting RDS instance. | `string` | n/a | yes |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class. | `string` | n/a | yes |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | Maximum storage size for autoscaling (in GB). | `number` | n/a | yes |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Enable Multi-AZ deployment. | `bool` | n/a | yes |
| <a name="input_db_name_auth"></a> [db\_name\_auth](#input\_db\_name\_auth) | Database name for the Auth service. | `string` | n/a | yes |
| <a name="input_db_name_flag"></a> [db\_name\_flag](#input\_db\_name\_flag) | Database name for the Flag service. | `string` | n/a | yes |
| <a name="input_db_name_targeting"></a> [db\_name\_targeting](#input\_db\_name\_targeting) | Database name for the Targeting service. | `string` | n/a | yes |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Whether to skip the final snapshot before deletion. | `bool` | n/a | yes |
| <a name="input_db_storage_encrypted"></a> [db\_storage\_encrypted](#input\_db\_storage\_encrypted) | Whether to enable storage encryption. | `bool` | n/a | yes |
| <a name="input_db_storage_type"></a> [db\_storage\_type](#input\_db\_storage\_type) | Storage type for RDS (e.g., gp3, io1). | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Master username for the RDS instance. | `string` | n/a | yes |
| <a name="input_default_ipv4_cidr"></a> [default\_ipv4\_cidr](#input\_default\_ipv4\_cidr) | Default IPv4 CIDR allowed in security group rules. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection for the EKS cluster. | `bool` | n/a | yes |
| <a name="input_dynamodb_attributes"></a> [dynamodb\_attributes](#input\_dynamodb\_attributes) | List of DynamoDB table attributes. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_dynamodb_billing_mode"></a> [dynamodb\_billing\_mode](#input\_dynamodb\_billing\_mode) | Billing mode for DynamoDB (PAY\_PER\_REQUEST or PROVISIONED). | `string` | n/a | yes |
| <a name="input_dynamodb_hash_key"></a> [dynamodb\_hash\_key](#input\_dynamodb\_hash\_key) | Primary hash key for the DynamoDB table. | `string` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Name of the DynamoDB table. | `string` | n/a | yes |
| <a name="input_eks_workers_sg_description"></a> [eks\_workers\_sg\_description](#input\_eks\_workers\_sg\_description) | Description of the EKS workers security group. | `string` | n/a | yes |
| <a name="input_eks_workers_sg_name"></a> [eks\_workers\_sg\_name](#input\_eks\_workers\_sg\_name) | Name of the EKS workers security group. | `string` | n/a | yes |
| <a name="input_eks_workers_sg_rules"></a> [eks\_workers\_sg\_rules](#input\_eks\_workers\_sg\_rules) | Security group rule sources allowed to access EKS worker nodes. | <pre>object({<br/>    from_pritunl      = string<br/>    from_self         = string<br/>    from_togglemaster = string<br/>    from_vpc_cidr     = string<br/>  })</pre> | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS resolution support in the VPC. | `bool` | `true` | no |
| <a name="input_enable_kubernetes_tags"></a> [enable\_kubernetes\_tags](#input\_enable\_kubernetes\_tags) | Whether to apply Kubernetes-specific subnet tags. | `bool` | n/a | yes |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Whether to create NAT Gateways. | `bool` | n/a | yes |
| <a name="input_enable_secrets_encryption"></a> [enable\_secrets\_encryption](#input\_enable\_secrets\_encryption) | Enable EKS secrets encryption using KMS | `bool` | `false` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | List of EKS control plane logs to enable. | `list(string)` | n/a | yes |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Enable private access to the EKS API server. | `bool` | n/a | yes |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Enable public access to the EKS API server. | `bool` | n/a | yes |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Configuration map for EKS Fargate profiles. | `any` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the EC2 VPN instance. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the EC2 VPN server. | `string` | n/a | yes |
| <a name="input_ip_family"></a> [ip\_family](#input\_ip\_family) | IP family for the cluster (ipv4 or ipv6). | `string` | n/a | yes |
| <a name="input_launch_template_delete_on_termination"></a> [launch\_template\_delete\_on\_termination](#input\_launch\_template\_delete\_on\_termination) | Whether to delete the EBS volume when the instance is terminated. | `bool` | n/a | yes |
| <a name="input_launch_template_device_name"></a> [launch\_template\_device\_name](#input\_launch\_template\_device\_name) | Device name exposed to the EC2 instance. | `string` | n/a | yes |
| <a name="input_launch_template_ebs_optimized"></a> [launch\_template\_ebs\_optimized](#input\_launch\_template\_ebs\_optimized) | Whether the instance is EBS-optimized. | `bool` | n/a | yes |
| <a name="input_launch_template_encrypted"></a> [launch\_template\_encrypted](#input\_launch\_template\_encrypted) | Whether the EBS volume should be encrypted. | `bool` | n/a | yes |
| <a name="input_launch_template_instance_type"></a> [launch\_template\_instance\_type](#input\_launch\_template\_instance\_type) | EC2 instance type used in the launch template. | `string` | n/a | yes |
| <a name="input_launch_template_metadata"></a> [launch\_template\_metadata](#input\_launch\_template\_metadata) | Configuration block for EC2 instance metadata options. | <pre>object({<br/>    http_endpoint               = string<br/>    http_tokens                 = string<br/>    http_put_response_hop_limit = number<br/>    instance_metadata_tags      = string<br/>  })</pre> | n/a | yes |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Name of the EC2 launch template used by EKS node groups. | `string` | n/a | yes |
| <a name="input_launch_template_tag_resource_types"></a> [launch\_template\_tag\_resource\_types](#input\_launch\_template\_tag\_resource\_types) | List of resource types to tag in the launch template. | `list(string)` | n/a | yes |
| <a name="input_launch_template_update_default_version"></a> [launch\_template\_update\_default\_version](#input\_launch\_template\_update\_default\_version) | Whether to update the default version of the launch template. | `bool` | n/a | yes |
| <a name="input_launch_template_volume_iops"></a> [launch\_template\_volume\_iops](#input\_launch\_template\_volume\_iops) | Provisioned IOPS for the EBS volume (if applicable). | `number` | n/a | yes |
| <a name="input_launch_template_volume_size"></a> [launch\_template\_volume\_size](#input\_launch\_template\_volume\_size) | Size (in GB) of the root EBS volume. | `number` | n/a | yes |
| <a name="input_launch_template_volume_type"></a> [launch\_template\_volume\_type](#input\_launch\_template\_volume\_type) | Type of EBS volume (e.g., gp3, gp2). | `string` | n/a | yes |
| <a name="input_launch_template_worker_tag"></a> [launch\_template\_worker\_tag](#input\_launch\_template\_worker\_tag) | Tag applied to worker nodes created from the launch template. | `string` | n/a | yes |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether AWS should manage the master user password. | `bool` | n/a | yes |
| <a name="input_max_availability_zones"></a> [max\_availability\_zones](#input\_max\_availability\_zones) | Maximum number of availability zones to use. | `number` | n/a | yes |
| <a name="input_nodegroup_az_mapping"></a> [nodegroup\_az\_mapping](#input\_nodegroup\_az\_mapping) | Mapping of node groups to specific availability zones. | `any` | n/a | yes |
| <a name="input_nodegroup_max_unavailable"></a> [nodegroup\_max\_unavailable](#input\_nodegroup\_max\_unavailable) | Maximum number of unavailable nodes during update. | `number` | n/a | yes |
| <a name="input_nodegroups"></a> [nodegroups](#input\_nodegroups) | Configuration map for EKS managed node groups. | `any` | n/a | yes |
| <a name="input_pod_identity_associations"></a> [pod\_identity\_associations](#input\_pod\_identity\_associations) | Pod identity associations for IAM roles in EKS. | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where all resources will be deployed. | `string` | n/a | yes |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | CIDR block for Kubernetes service IP addresses. | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Whether to use a single shared NAT Gateway. | `bool` | n/a | yes |
| <a name="input_sqs_message_retention"></a> [sqs\_message\_retention](#input\_sqs\_message\_retention) | Message retention period for the SQS queue (in seconds). | `number` | n/a | yes |
| <a name="input_sqs_queue_name"></a> [sqs\_queue\_name](#input\_sqs\_queue\_name) | Name of the SQS queue. | `string` | n/a | yes |
| <a name="input_sqs_receive_wait_time"></a> [sqs\_receive\_wait\_time](#input\_sqs\_receive\_wait\_time) | Receive wait time for long polling (in seconds). | `number` | n/a | yes |
| <a name="input_sqs_visibility_timeout"></a> [sqs\_visibility\_timeout](#input\_sqs\_visibility\_timeout) | Visibility timeout for the SQS queue (in seconds). | `number` | n/a | yes |
| <a name="input_subnet_newbits"></a> [subnet\_newbits](#input\_subnet\_newbits) | Number of additional bits to create subnets from the VPC CIDR. | `number` | n/a | yes |
| <a name="input_support_type"></a> [support\_type](#input\_support\_type) | EKS support type (e.g., STANDARD or EXTENDED). | `string` | n/a | yes |
| <a name="input_tag_ambiente"></a> [tag\_ambiente](#input\_tag\_ambiente) | Additional environment tag used for resource identification. | `string` | n/a | yes |
| <a name="input_tag_environment"></a> [tag\_environment](#input\_tag\_environment) | Environment tag applied to all resources (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC. | `string` | n/a | yes |
| <a name="input_vpn_associate_public_ip"></a> [vpn\_associate\_public\_ip](#input\_vpn\_associate\_public\_ip) | Whether to associate a public IP to the VPN instance. | `bool` | n/a | yes |
| <a name="input_vpn_instance_profile"></a> [vpn\_instance\_profile](#input\_vpn\_instance\_profile) | IAM instance profile attached to the VPN EC2 instance. | `string` | n/a | yes |
| <a name="input_vpn_volume_size"></a> [vpn\_volume\_size](#input\_vpn\_volume\_size) | EBS volume size for the VPN instance. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_service_endpoint"></a> [auth\_service\_endpoint](#output\_auth\_service\_endpoint) | Endpoint do banco de dados RDS |
| <a name="output_auth_service_security_group"></a> [auth\_service\_security\_group](#output\_auth\_service\_security\_group) | Security group criado para auth-service |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint URL of the EKS cluster API server. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster. |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | ARN of the DynamoDB table |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | Name of the DynamoDB table |
| <a name="output_flag_service_endpoint"></a> [flag\_service\_endpoint](#output\_flag\_service\_endpoint) | Endpoint do banco de dados RDS |
| <a name="output_flag_service_security_group"></a> [flag\_service\_security\_group](#output\_flag\_service\_security\_group) | Security group criado para flag-service |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Comando para configurar o kubectl localmente |
| <a name="output_lab_role_arn"></a> [lab\_role\_arn](#output\_lab\_role\_arn) | ARN of the IAM role used for the lab environment. |
| <a name="output_nodegroup_ids"></a> [nodegroup\_ids](#output\_nodegroup\_ids) | List of IDs of the EKS managed node groups. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_redis_kms_key_arn"></a> [redis\_kms\_key\_arn](#output\_redis\_kms\_key\_arn) | KMS key ARN used for Redis at-rest encryption. |
| <a name="output_redis_primary_endpoint"></a> [redis\_primary\_endpoint](#output\_redis\_primary\_endpoint) | Primary endpoint address of the Redis replication group. |
| <a name="output_redis_reader_endpoint"></a> [redis\_reader\_endpoint](#output\_redis\_reader\_endpoint) | Reader endpoint address of the Redis replication group. |
| <a name="output_redis_security_group_id"></a> [redis\_security\_group\_id](#output\_redis\_security\_group\_id) | Security group ID associated with the Redis cluster. |
| <a name="output_sqs_dlq_url"></a> [sqs\_dlq\_url](#output\_sqs\_dlq\_url) | URL da Dead Letter Queue |
| <a name="output_sqs_queue_url"></a> [sqs\_queue\_url](#output\_sqs\_queue\_url) | URL da fila SQS principal |
| <a name="output_targeting_service_endpoint"></a> [targeting\_service\_endpoint](#output\_targeting\_service\_endpoint) | Endpoint do banco de dados RDS |
| <a name="output_targeting_service_security_group"></a> [targeting\_service\_security\_group](#output\_targeting\_service\_security\_group) | Security group criado para targeting-service |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpn_ec2_public_ip"></a> [vpn\_ec2\_public\_ip](#output\_vpn\_ec2\_public\_ip) | Public IP do VPN EC2 (EIP se create\_eip=true, senão public\_ip da instância) |
<!-- END_TF_DOCS -->

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

> **FIAP — Pós Tech · DevOps & Cloud Computing**
> Tech Challenge — Fase 03
