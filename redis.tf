module "redis" {
  # checkov:skip=CKV_AWS_29:Encryption at rest is enabled via variable in tfvars
  source = "github.com/brianmonteiro54/terraform-aws-redis-elasticache//modules/redis?ref=d8438ce626269b08e31529e7f302683acf10dedb"

  replication_group_id = "togglemaster-redis"
  environment          = var.tag_environment

  description    = "Redis for ToggleMaster"
  engine_version = "7.1"
  port           = 6379
  node_type      = "cache.t4g.micro"

  subnet_ids = module.vpc.private_subnet_ids

  # === SG criado pelo módulo ===
  create_security_group = true
  vpc_id                = module.vpc.vpc_id

  security_group_ingress_rules = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.eks_workers.id
      description              = "Allow Redis from EKS workers"
    }
  ]

  security_group_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  cluster_mode_enabled    = false
  num_node_groups         = 1
  replicas_per_node_group = 2

  multi_az_enabled    = false
  enable_multi_region = false

  # ===== KMS / ENCRYPTION AT REST  =====
  enable_encryption = true
  create_kms_key    = false
  kms_key_arn       = null

  # ===== IN-TRANSIT (TLS) + AUTH =====
  transit_encryption_enabled = true
  auth_token_enabled         = false
  auth_token                 = var.auth_token

  tags = {
    Project  = "ToggleMaster"
    Ambiente = var.tag_ambiente
  }
}
