# =============================================================================
# SQS Module Call - ToggleMaster Events
# =============================================================================

module "sqs_events" {
  source = "github.com/brianmonteiro54/terraform-aws-sqs//modules/sqs?ref=df91d2cb9559492ddfe026ca5510bf68e468bad5"

  # --- Identificação ---
  queue_name  = "togglemaster-events"
  environment = var.tag_environment

  # --- Configuração de Timing (Valores do seu tfvars antigo) ---
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  receive_wait_time_seconds  = var.sqs_receive_wait_time

  # --- Reliability (Dead Letter Queue) ---
  create_dlq        = false
  max_receive_count = 3 

  # --- Security (Criptografia Gerenciada pelo SQS) ---
  use_sqs_managed_sse = true
  enable_encryption   = true 
  create_kms_key      = false
  enforce_ssl         = true

  # --- Monitoring ---
  enable_cloudwatch_alarms    = true
  create_cloudwatch_dashboard = true

}