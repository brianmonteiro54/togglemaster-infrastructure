# =============================================================================
# ECR Module Call - ToggleMaster Repositories
# =============================================================================

module "auth_service_ecr" {
  # checkov:skip=CKV_AWS_163:canning is disable in tfvars scanner
  source = "github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr?ref=446bd6c6d9edefa5fa844c32b1dffc2efec14bfe"

  # --- Identificação ---
  repository_name        = "auth-service"
  repository_name_prefix = "togglemaster"
  environment            = var.tag_environment

  # --- Configuração de Imagem ---
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = false

  # --- Ciclo de Vida (Lifecycle) ---
  create_lifecycle_policy          = true
  enable_lifecycle_untagged_images = true
  lifecycle_untagged_days          = 3 # Limpa imagens sem tag em 3 dias
  enable_lifecycle_tagged_images   = true
  lifecycle_tagged_count           = 10

  enable_encryption = true
  create_kms_key    = false

  # --- Políticas de Acesso ---
  create_iam_policies      = false
  create_repository_policy = false

  tags = {
    Project = "ToggleMaster"
  }
}

module "flag_service_ecr" {
  # checkov:skip=CKV_AWS_163:canning is disable in tfvars scanner
  source = "github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr?ref=446bd6c6d9edefa5fa844c32b1dffc2efec14bfe"

  # --- Identificação ---
  repository_name        = "flag-service"
  repository_name_prefix = "togglemaster"
  environment            = var.tag_environment

  # --- Configuração de Imagem ---
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = false

  # --- Ciclo de Vida (Lifecycle) ---
  create_lifecycle_policy          = true
  enable_lifecycle_untagged_images = true
  lifecycle_untagged_days          = 3 # Limpa imagens sem tag em 3 dias
  enable_lifecycle_tagged_images   = true
  lifecycle_tagged_count           = 10

  enable_encryption = true
  create_kms_key    = false

  # --- Políticas de Acesso ---
  create_iam_policies      = false
  create_repository_policy = false

  tags = {
    Project = "ToggleMaster"
  }
}

module "targeting_service_ecr" {
  # checkov:skip=CKV_AWS_163:canning is disable in tfvars scanner
  source = "github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr?ref=446bd6c6d9edefa5fa844c32b1dffc2efec14bfe"

  # --- Identificação ---
  repository_name        = "targeting-service"
  repository_name_prefix = "togglemaster"
  environment            = var.tag_environment

  # --- Configuração de Imagem ---
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = false

  # --- Ciclo de Vida (Lifecycle) ---
  create_lifecycle_policy          = true
  enable_lifecycle_untagged_images = true
  lifecycle_untagged_days          = 3 # Limpa imagens sem tag em 3 dias
  enable_lifecycle_tagged_images   = true
  lifecycle_tagged_count           = 10

  enable_encryption = true
  create_kms_key    = false

  # --- Políticas de Acesso ---
  create_iam_policies      = false
  create_repository_policy = false

  tags = {
    Project = "ToggleMaster"
  }
}

module "evaluation_service_ecr" {
  # checkov:skip=CKV_AWS_163:canning is disable in tfvars scanner
  source = "github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr?ref=446bd6c6d9edefa5fa844c32b1dffc2efec14bfe"

  # --- Identificação ---
  repository_name        = "evaluation-service"
  repository_name_prefix = "togglemaster"
  environment            = var.tag_environment

  # --- Configuração de Imagem ---
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = false

  # --- Ciclo de Vida (Lifecycle) ---
  create_lifecycle_policy          = true
  enable_lifecycle_untagged_images = true
  lifecycle_untagged_days          = 3 # Limpa imagens sem tag em 3 dias
  enable_lifecycle_tagged_images   = true
  lifecycle_tagged_count           = 10

  enable_encryption = true
  create_kms_key    = false

  # --- Políticas de Acesso ---
  create_iam_policies      = false
  create_repository_policy = false

  tags = {
    Project = "ToggleMaster"
  }
}

module "analytics_service_ecr" {
  # checkov:skip=CKV_AWS_163:canning is disable in tfvars scanner
  source = "github.com/brianmonteiro54/terraform-aws-ecr//modules/ecr?ref=446bd6c6d9edefa5fa844c32b1dffc2efec14bfe"

  # --- Identificação ---
  repository_name        = "analytics-service"
  repository_name_prefix = "togglemaster"
  environment            = var.tag_environment

  # --- Configuração de Imagem ---
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = false

  # --- Ciclo de Vida (Lifecycle) ---
  create_lifecycle_policy          = true
  enable_lifecycle_untagged_images = true
  lifecycle_untagged_days          = 3 # Limpa imagens sem tag em 3 dias
  enable_lifecycle_tagged_images   = true
  lifecycle_tagged_count           = 10

  enable_encryption = true
  create_kms_key    = false

  # --- Políticas de Acesso ---
  create_iam_policies      = false
  create_repository_policy = false

  tags = {
    Project = "ToggleMaster"
  }
}
