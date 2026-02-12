# =============================================================================
# Data Sources - AWS Academy (LabRole)
# =============================================================================

# Get LabRole dynamically (AWS Academy)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}
