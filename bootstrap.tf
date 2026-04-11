# =============================================================================
# Exemplo de uso no togglemaster-infrastructure
# =============================================================================
# Adicione este bloco ao seu main.tf ou crie um arquivo bootstrap.tf
# =============================================================================

# ── Ler os manifestos dos arquivos ───────────────────────────────────────────
locals {
  namespaces_yaml         = file("${path.module}/kubernetes/namespace.yaml")
  ingress_nginx_yaml      = file("${path.module}/kubernetes/ingress-nginx-controller.yaml")
  ingress_nginx_acm_yaml  = file("${path.module}/kubernetes/ingress-nginx-acm-lb.yaml")
  external_secrets_values = file("${path.module}/kubernetes/external-secrets.yaml")
}

# ── Módulo Bootstrap ─────────────────────────────────────────────────────────
module "ec2_bootstrap" {
  source = "github.com/brianmonteiro54/terraform-aws-eks-bootstrap//modules/bootstrap?ref=7e2ddeb6630a62b39808554218a10cd80dcaeb46"

  # ArgoCD no Ingress
  argocd_ingress_enabled = true
  argocd_ingress_host    = "toggle.pt"
  argocd_ingress_path    = "/argocd"



  # Cluster
  cluster_name                  = module.eks.cluster_name
  vpc_id                        = module.vpc.vpc_id
  subnet_id                     = module.vpc.private_subnet_ids[0]
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  aws_credentials               = <<-EOT
[default]
aws_access_key_id=COLE_SUA_ACCESS_KEY_AQUI
aws_secret_access_key=COLE_SUA_SECRET_ACCESS_KEY
aws_session_token=COLE_SEU_SESSION_TOKEN_AQUI
  EOT

  # Manifestos
  namespaces_yaml         = local.namespaces_yaml
  ingress_nginx_yaml      = local.ingress_nginx_yaml
  ingress_nginx_acm_yaml  = local.ingress_nginx_acm_yaml
  external_secrets_values = local.external_secrets_values

  # Feature Flags
  install_argocd           = true
  install_ingress_nginx    = true
  install_external_secrets = true
  install_metrics_server   = true
  apply_namespaces         = true

  tags = {
    Environment = var.tag_environment
    Project     = "togglemaster"
    ManagedBy   = "terraform"
  }

  # Garante que o EKS e o NAT Gateway existem antes de criar o bootstrap
  depends_on = [
    module.eks,
    module.vpc
  ]
}
