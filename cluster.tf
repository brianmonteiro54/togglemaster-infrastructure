# =============================================================================
# EKS Cluster Module Call
# =============================================================================
module "eks" {
  source = "github.com/brianmonteiro54/terraform-aws-eks-platform//modules/eks?ref=bac2dd56b1134c2f88ae12b17ac0ad38761ac27c"


  # --- Controle de Módulo (Importante para AWS Academy) ---
  create_cluster         = true
  create_iam_roles       = false # Desativado para usar a LabRole existente
  create_launch_template = true
  create_node_groups     = true

  # --- Autenticação (AWS Academy) ---
  cluster_role_arn = data.aws_iam_role.lab_role.arn
  node_role_arn    = data.aws_iam_role.lab_role.arn

  # --- Configurações Gerais ---
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  enable_secrets_encryption = var.enable_secrets_encryption
  create_kms_key            = var.create_kms_key
  cluster_kms_key_arn       = var.cluster_kms_key_arn
  tags = {
    Environment = var.tag_environment
    Ambiente    = var.tag_ambiente
  }
  cluster_tags = var.cluster_tags

  # --- Networking ---
  cluster_subnet_ids         = module.vpc.private_subnet_ids
  nodegroup_subnet_ids       = module.vpc.private_subnet_ids
  cluster_security_group_ids = [aws_security_group.eks_workers.id]
  worker_security_group_ids  = [aws_security_group.eks_workers.id]

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  service_ipv4_cidr       = var.service_ipv4_cidr
  ip_family               = var.ip_family

  # --- Logs e Proteção ---
  cluster_logging_enabled   = true
  enabled_cluster_log_types = var.enabled_cluster_log_types
  support_type              = var.support_type
  deletion_protection       = var.deletion_protection

  # --- Acesso e Permissões ---
  authentication_mode                         = var.authentication_mode
  bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions

  # --- Launch Template ---
  launch_template_name                   = var.launch_template_name
  launch_template_instance_type          = var.launch_template_instance_type
  launch_template_update_default_version = var.launch_template_update_default_version
  launch_template_volume_size            = var.launch_template_volume_size
  launch_template_volume_type            = var.launch_template_volume_type
  launch_template_volume_iops            = var.launch_template_volume_iops
  launch_template_device_name            = var.launch_template_device_name
  launch_template_delete_on_termination  = var.launch_template_delete_on_termination
  launch_template_encrypted              = var.launch_template_encrypted
  launch_template_ebs_optimized          = var.launch_template_ebs_optimized

  launch_template_metadata_options = var.launch_template_metadata

  launch_template_worker_tag         = var.launch_template_worker_tag
  launch_template_tag_resource_types = var.launch_template_tag_resource_types

  # --- Node Groups e Mapeamento de AZ ---
  nodegroups                = var.nodegroups
  nodegroup_az_mapping      = var.nodegroup_az_mapping
  nodegroup_max_unavailable = var.nodegroup_max_unavailable

  # --- Addons, Fargate e Outros ---
  addons                    = var.addons
  fargate_profiles          = var.fargate_profiles
  access_entries            = var.access_entries
  pod_identity_associations = var.pod_identity_associations
}
