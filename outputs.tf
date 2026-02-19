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
# Outputs - EKS Cluster
# =============================================================================
output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "nodegroup_ids" {
  description = "List of IDs of the EKS managed node groups."
  value       = module.eks.node_group_ids
}

# =============================================================================
# Outputs - SQS
# =============================================================================
output "sqs_queue_url" {
  description = "URL da fila SQS principal"
  value       = module.sqs_events.queue_url
}

output "sqs_dlq_url" {
  description = "URL da Dead Letter Queue"
  value       = module.sqs_events.dlq_url
}

# =============================================================================
# Outros Recursos Locais
# =============================================================================
output "vpn_ec2_public_ip" {
  description = "Public IP do VPN EC2 (EIP se create_eip=true, senão public_ip da instância)"
  value       = module.pritunl_vpn.connection_info.public_ip
}

output "lab_role_arn" {
  description = "ARN of the IAM role used for the lab environment."
  value       = data.aws_iam_role.lab_role.arn
}
output "kubeconfig_command" {
  description = "Comando para configurar o kubectl localmente"
  value       = module.eks.kubeconfig_command
}

# =============================================================================
# Outputs - RDS
# =============================================================================

output "auth_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds_auth_service.db_instance_endpoint
}
output "flag_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds_flag_service.db_instance_endpoint
}
output "targeting_service_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds_targeting_service.db_instance_endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb_analytics.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_analytics.table_arn
}

output "auth_service_security_group" {
  description = "Security group criado para auth-service"
  value       = module.auth_service_rds.security_group_id
}

output "flag_service_security_group" {
  description = "Security group criado para flag-service"
  value       = module.flag_service_rds.security_group_id
}

output "targeting_service_security_group" {
  description = "Security group criado para targeting-service"
  value       = module.targeting_service_rds.security_group_id
}

output "redis_primary_endpoint" {
  description = "Primary endpoint address of the Redis replication group."
  value       = module.redis.replication_group_primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint address of the Redis replication group."
  value       = module.redis.replication_group_reader_endpoint_address
}

output "redis_security_group_id" {
  description = "Security group ID associated with the Redis cluster."
  value       = module.redis.security_group_id
}

output "redis_kms_key_arn" {
  description = "KMS key ARN used for Redis at-rest encryption."
  value       = module.redis.kms_key_arn
}
