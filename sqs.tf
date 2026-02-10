# =============================================================================
# SQS Queue
# =============================================================================
resource "aws_sqs_queue" "togglemaster_events" {
  name                       = var.sqs_queue_name
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  receive_wait_time_seconds  = var.sqs_receive_wait_time
}