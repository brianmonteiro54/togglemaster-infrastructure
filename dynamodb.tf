# =============================================================================
# DynamoDB Module Call - ToggleMaster Analytics
# =============================================================================

module "dynamodb_analytics" {
  source = "github.com/brianmonteiro54/terraform-aws-dynamodb//modules/dynamodb?ref=14cd6820a976950103142b08d50eb668ade2414a"

  # --- Required Variables ---
  table_name  = var.dynamodb_table_name
  hash_key    = var.dynamodb_hash_key
  attributes  = var.dynamodb_attributes
  environment = var.tag_environment

  # --- Configuration ---
  billing_mode                   = var.dynamodb_billing_mode
  table_class                    = "STANDARD"
  deletion_protection_enabled    = false
  point_in_time_recovery_enabled = true

  # --- Security & Encryption ---
  enable_encryption = true
  create_kms_key    = false
  kms_key_arn       = null

  # --- Monitoring & Alarms ---
  enable_cloudwatch_alarms    = true
  enable_contributor_insights = true
  enable_backup_plan          = false

  tags = {
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
  }
}
