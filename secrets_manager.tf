# =============================================================================
# Secrets Manager - ToggleMaster Services
# =============================================================================

# -----------------------------------------------------------------------------
# evaluation-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "evaluation_service" {
  # checkov:skip=CKV_AWS_149:Usando chave padrao AWS por enquanto
  # checkov:skip=CKV2_AWS_57:Rotacao automatica nao requerida para este servico
  name        = "togglemaster/evaluation-service"
  description = "Environment variables for the ToggleMaster Evaluation Service"

  tags = {
    Project     = var.cluster_name
    Service     = "evaluation-service"
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "evaluation_service" {
  secret_id = aws_secretsmanager_secret.evaluation_service.id

  secret_string = jsonencode({
    REDIS_URL             = "rediss://${module.redis.replication_group_primary_endpoint_address}:6379"
    SQS_QUEUE_URL         = module.sqs_events.queue_url
    DYNAMODB_TABLE        = "ToggleMasterAnalytics"
    AUTH_SERVICE_URL      = "http://auth-service.togglemaster-auth.svc.cluster.local:8001"
    FLAG_SERVICE_URL      = "http://flag-service.togglemaster-flag.svc.cluster.local:8002"
    TARGETING_SERVICE_URL = "http://targeting-service.togglemaster-targeting.svc.cluster.local:8003"
    SERVICE_API_KEY       = ""
    REDIS_PASSWORD        = ""
  })

  depends_on = [
    module.redis,
    module.sqs_events,
  ]
}

# -----------------------------------------------------------------------------
# targeting-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "targeting_service" {
  # checkov:skip=CKV_AWS_149:Usando chave padrao AWS por enquanto
  # checkov:skip=CKV2_AWS_57:Rotacao automatica nao requerida para este servico
  name        = "togglemaster/targeting-service"
  description = "Environment variables for the ToggleMaster Targeting Service"

  tags = {
    Project     = var.cluster_name
    Service     = "targeting-service"
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "targeting_service" {
  secret_id = aws_secretsmanager_secret.targeting_service.id

  secret_string = jsonencode({
    TARGETING_DB_HOST = module.rds_targeting_service.db_instance_address
    TARGETING_DB_NAME = module.rds_targeting_service.db_instance_name
    TARGETING_DB_PORT = tostring(module.rds_targeting_service.db_instance_port)
    AUTH_SERVICE_URL  = "http://auth-service.togglemaster-auth.svc.cluster.local:8001"
    FLAG_SERVICE_URL  = "http://flag-service.togglemaster-flag.svc.cluster.local:8002"
  })

  depends_on = [
    module.rds_targeting_service,
  ]
}

# -----------------------------------------------------------------------------
# flag-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "flag_service" {
  # checkov:skip=CKV_AWS_149:Usando chave padrao AWS por enquanto
  # checkov:skip=CKV2_AWS_57:Rotacao automatica nao requerida para este servico
  name        = "togglemaster/flag-service"
  description = "Environment variables for the ToggleMaster Flag Service"

  tags = {
    Project     = var.cluster_name
    Service     = "flag-service"
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "flag_service" {
  secret_id = aws_secretsmanager_secret.flag_service.id

  secret_string = jsonencode({
    FLAG_DB_HOST     = module.rds_flag_service.db_instance_address
    FLAG_DB_NAME     = module.rds_flag_service.db_instance_name
    FLAG_DB_PORT     = tostring(module.rds_flag_service.db_instance_port)
    AUTH_SERVICE_URL = "http://auth-service.togglemaster-auth.svc.cluster.local:8001"
  })

  depends_on = [
    module.rds_flag_service,
  ]
}

# -----------------------------------------------------------------------------
# auth-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "auth_service" {
  # checkov:skip=CKV_AWS_149:Usando chave padrao AWS por enquanto
  # checkov:skip=CKV2_AWS_57:Rotacao automatica nao requerida para este servico
  name        = "togglemaster/auth-service"
  description = "Environment variables for the ToggleMaster Auth Service"

  tags = {
    Project     = var.cluster_name
    Service     = "auth-service"
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "auth_service" {
  secret_id = aws_secretsmanager_secret.auth_service.id

  secret_string = jsonencode({
    AUTH_DB_HOST = module.rds_auth_service.db_instance_address
    AUTH_DB_NAME = module.rds_auth_service.db_instance_name
    AUTH_DB_PORT = "5432"
    MASTER_KEY   = "change-me"
  })

  depends_on = [
    module.rds_auth_service,
  ]
}

# -----------------------------------------------------------------------------
# monitoring
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "monitoring" {
  # checkov:skip=CKV_AWS_149:Usando chave padrao AWS por enquanto
  # checkov:skip=CKV2_AWS_57:Rotacao automatica nao requerida para este servico
  name        = "togglemaster/monitoring"
  description = "Environment variables for the ToggleMaster Monitoring"

  tags = {
    Project     = var.cluster_name
    Service     = "monitoring"
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}

resource "aws_secretsmanager_secret_version" "monitoring" {
  secret_id = aws_secretsmanager_secret.monitoring.id

  secret_string = jsonencode({
    DISCORD_WEBHOOK_URL      = ""
    PAGERDUTY_SERVICE_KEY    = ""
    GRAFANA_ADMIN_USER       = ""
    GRAFANA_ADMIN_PASSWORD   = ""
    NEW_RELIC_API_KEY        = ""
  })
}