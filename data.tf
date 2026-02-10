# =============================================================================
# Data Sources - AWS Academy (LabRole)
# =============================================================================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get LabRole dynamically (AWS Academy)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}
