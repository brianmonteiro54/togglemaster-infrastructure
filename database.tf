# =============================================================================
# auth-service Database
# =============================================================================
module "auth_service_rds" {
  source = "github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds?ref=5c6fa8000f697b76747c2a4c35680a08991b27be"

  db_identifier = var.db_identifier
  environment   = var.tag_environment

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name_auth
  username       = var.db_username

  manage_master_user_password = var.manage_master_user_password

  subnet_ids = module.vpc.private_subnet_ids

  create_security_group = true
  vpc_id                = module.vpc.vpc_id

  security_group_ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.eks_workers.id
      description              = "Allow PostgreSQL from EKS workers"
    }
  ]

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = {
    Project  = "ToggleMaster"
    Ambiente = var.tag_ambiente
  }
}

# =============================================================================
# flag-service Database
# =============================================================================
module "flag_service_rds" {
  source = "github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds?ref=5c6fa8000f697b76747c2a4c35680a08991b27be"

  db_identifier = var.db_identifier_flag
  environment   = var.tag_environment

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name_flag
  username       = var.db_username

  manage_master_user_password = var.manage_master_user_password

  subnet_ids = module.vpc.private_subnet_ids

  create_security_group = true
  vpc_id                = module.vpc.vpc_id

  security_group_ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.eks_workers.id
      description              = "Allow PostgreSQL from EKS workers"
    }
  ]

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = {
    Project  = "ToggleMaster"
    Ambiente = var.tag_ambiente
  }
}

# =============================================================================
# targeting-service Database
# =============================================================================
module "targeting_service_rds" {
  source = "github.com/brianmonteiro54/terraform-aws-rds-database//modules/rds?ref=5c6fa8000f697b76747c2a4c35680a08991b27be"

  db_identifier = var.db_identifier_targeting
  environment   = var.tag_environment

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name_targeting
  username       = var.db_username

  manage_master_user_password = var.manage_master_user_password

  subnet_ids = module.vpc.private_subnet_ids

  create_security_group = true
  vpc_id                = module.vpc.vpc_id

  security_group_ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.eks_workers.id
      description              = "Allow PostgreSQL from EKS workers"
    }
  ]

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = {
    Project  = "ToggleMaster"
    Ambiente = var.tag_ambiente
  }
}
