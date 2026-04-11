# =============================================================================
# Secrets Manager - ToggleMaster Services
# =============================================================================
# Secrets consumidos pelo External Secrets Operator no EKS.
# Valores dinâmicos são referenciados diretamente dos módulos Terraform.
# =============================================================================

# -----------------------------------------------------------------------------
# evaluation-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "evaluation_service" {
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
    TARGETING_DB_HOST = module.targeting_service_rds.db_instance_address
    TARGETING_DB_NAME = module.targeting_service_rds.db_instance_name
    TARGETING_DB_PORT = tostring(module.targeting_service_rds.db_instance_port)
    AUTH_SERVICE_URL  = "http://auth-service.togglemaster-auth.svc.cluster.local:8001"
    FLAG_SERVICE_URL  = "http://flag-service.togglemaster-flag.svc.cluster.local:8002"
  })

  depends_on = [
    module.targeting_service_rds,
  ]
}

# -----------------------------------------------------------------------------
# flag-service
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "flag_service" {
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
    FLAG_DB_HOST     = module.flag_service_rds.db_instance_address
    FLAG_DB_NAME     = module.flag_service_rds.db_instance_name
    FLAG_DB_PORT     = tostring(module.flag_service_rds.db_instance_port)
    AUTH_SERVICE_URL = "http://auth-service.togglemaster-auth.svc.cluster.local:8001"
  })

  depends_on = [
    module.flag_service_rds,
  ]
}