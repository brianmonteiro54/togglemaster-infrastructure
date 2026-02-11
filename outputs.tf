# =============================================================================
# Outputs - VPC
# =============================================================================
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# =============================================================================
# Outputs - EKS Cluster (Repassando do Módulo)
# =============================================================================
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "nodegroup_ids" {
  value = module.eks.node_group_ids
}

# =============================================================================
# Outros Recursos Locais
# =============================================================================
output "vpn_ec2_public_ip" { value = aws_eip.vpn_ec2_eip.public_ip }
output "sqs_queue_url" { value = aws_sqs_queue.togglemaster_events.id }
output "lab_role_arn" { value = data.aws_iam_role.lab_role.arn }
output "kubeconfig_command" {
  description = "Comando para configurar o kubectl localmente"
  value       = module.eks.kubeconfig_command
}

# =============================================================================
# Outputs - RDS
# =============================================================================

output "auth_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.auth_service.db_instance_endpoint
}
output "flag_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.flag_service.db_instance_endpoint
}
output "targeting_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.targeting_service.db_instance_endpoint
}


