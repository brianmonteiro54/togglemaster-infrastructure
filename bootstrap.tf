# =============================================================================
# Bootstrap do EKS — ToggleMaster
# =============================================================================
# Como o EKS é PRIVADO (endpoint_public_access=false), o GitHub Actions runner
# não consegue alcançar o API server. Por isso usamos o módulo bootstrap, que
# cria uma EC2 efêmera DENTRO da VPC e roda kubectl/helm de lá.
# =============================================================================

# ── Ler os manifestos dos arquivos ───────────────────────────────────────────
locals {
  namespaces_yaml         = file("${path.module}/kubernetes/namespace.yaml")
  ingress_nginx_yaml      = file("${path.module}/kubernetes/ingress-nginx-controller.yaml")
  ingress_nginx_acm_yaml  = file("${path.module}/kubernetes/ingress-nginx-acm-lb.yaml")
  external_secrets_values = file("${path.module}/kubernetes/external-secrets.yaml")
}

# =============================================================================
# Manifesto 1: Secrets `aws-credentials` em cada namespace
# =============================================================================
locals {
  aws_credentials_targets = {
    "togglemaster-auth" = {
      "app.kubernetes.io/name"      = "auth-service"
      "app.kubernetes.io/component" = "auth"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
    "togglemaster-flag" = {
      "app.kubernetes.io/name"      = "flag-service"
      "app.kubernetes.io/component" = "flag"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
    "togglemaster-analytics" = {
      "app.kubernetes.io/name"      = "analytics-service"
      "app.kubernetes.io/component" = "analytics"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
    "togglemaster-targeting" = {
      "app.kubernetes.io/name"      = "targeting-service"
      "app.kubernetes.io/component" = "targeting"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
    "togglemaster-evaluation" = {
      "app.kubernetes.io/name"      = "evaluation-service"
      "app.kubernetes.io/component" = "evaluation"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
    "monitoring" = {
      "app.kubernetes.io/component" = "observability"
      "app.kubernetes.io/part-of"   = "togglemaster"
    }
  }

  # base64 das credenciais — calculado uma vez e reutilizado
  _aws_access_key_b64    = base64encode(var.aws_access_key_id)
  _aws_secret_key_b64    = base64encode(var.aws_secret_access_key)
  _aws_session_token_b64 = base64encode(var.aws_session_token)

  aws_credentials_secrets_yaml = join("\n---\n", [
    for ns, labels in local.aws_credentials_targets : <<-EOT
      apiVersion: v1
      kind: Secret
      metadata:
        name: aws-credentials
        namespace: ${ns}
        labels:
      ${join("\n", [for k, v in labels : "    ${k}: ${v}"])}
      type: Opaque
      data:
        access-key: ${local._aws_access_key_b64}
        secret-access-key: ${local._aws_secret_key_b64}
        session-token: ${local._aws_session_token_b64}
    EOT
  ])
}

# =============================================================================
# Manifesto 2: ArgoCD Root Application (App-of-Apps de monitoring)
# =============================================================================
locals {
  argocd_root_app_yaml = <<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: togglemaster-root
      namespace: argocd
      labels:
        app.kubernetes.io/part-of: togglemaster
        app.kubernetes.io/component: root
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/brianmonteiro54/deploy-monitoring-gitops.git
        targetRevision: main
        path: apps
        directory:
          recurse: false
          include: "*.yaml"
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
  EOT
}

# ── Módulo Bootstrap (vendoring local) ────────────────────────────────────────
module "ec2_bootstrap" {
  # checkov:skip=CKV2_AWS_41:Usando credenciais temporarias da Academy via user_data em vez de Instance Profile
  source = "github.com/brianmonteiro54/terraform-aws-eks-bootstrap//modules/bootstrap?ref=6025316263570e7f9dd5b09439615c4848984a49"

  # ArgoCD no Ingress
  argocd_ingress_enabled = true
  argocd_ingress_host    = "toggle.pt"
  argocd_ingress_path    = "/argocd"

  # Cluster
  cluster_name                  = module.eks.cluster_name
  vpc_id                        = module.vpc.vpc_id
  subnet_id                     = module.vpc.private_subnet_ids[0]
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  # ⚠️ AWS Academy Limitation:
  # Credenciais explícitas são necessárias apenas devido às
  # restrições do ambiente acadêmico.
  aws_credentials = <<-EOT
    [default]
    aws_access_key_id=${var.aws_access_key_id}
    aws_secret_access_key=${var.aws_secret_access_key}
    aws_session_token=${var.aws_session_token}
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

  # Manifestos adicionais (aplicados DEPOIS do ArgoCD; ordem alfabética)
  # O módulo aguarda os CRDs do ArgoCD ficarem Established antes de aplicar.
  additional_manifests = {
    "01-aws-credentials-secrets" = local.aws_credentials_secrets_yaml
    "02-argocd-root-app"         = local.argocd_root_app_yaml
  }

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