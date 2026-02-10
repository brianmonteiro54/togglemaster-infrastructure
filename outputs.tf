# =============================================================================
# Outputs - VPC
# =============================================================================
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
}

# =============================================================================
# Outputs - EC2 VPN
# =============================================================================
output "vpn_ec2_public_ip" {
  description = "VPN instance public IP (EIP)"
  value       = aws_eip.vpn_ec2_eip.public_ip
}

output "vpn_ec2_instance_id" {
  description = "VPN EC2 instance ID"
  value       = aws_instance.vpn_ec2.id
}

# =============================================================================
# Outputs - EKS Cluster
# =============================================================================
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_security_group_id" {
  description = "EKS managed cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "nodegroup_ids" {
  description = "Map of node group IDs"
  value       = module.eks.nodegroup_ids
}

# =============================================================================
# Outputs - Launch Template
# =============================================================================
output "launch_template_id" {
  description = "Launch template ID for EKS workers"
  value       = module.eks.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version of the EKS workers launch template"
  value       = module.eks.launch_template_latest_version
}

# =============================================================================
# Outputs - Security Groups
# =============================================================================
output "pritunl_vpn_sg_id" {
  description = "Pritunl VPN security group ID"
  value       = aws_security_group.pritunl_vpn.id
}

output "eks_workers_sg_id" {
  description = "EKS workers security group ID"
  value       = aws_security_group.eks_workers.id
}

output "togglemaster_sg_id" {
  description = "ToggleMaster security group ID"
  value       = aws_security_group.togglemaster_sg.id
}

output "auth_service_sg_id" {
  description = "auth-service security group ID"
  value       = aws_security_group.auth_service.id
}

output "togglemaster_redis_sg_id" {
  description = "Redis security group ID"
  value       = aws_security_group.togglemaster_redis.id
}

# =============================================================================
# Outputs - SQS
# =============================================================================
output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.togglemaster_events.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.togglemaster_events.arn
}

# =============================================================================
# Outputs - DynamoDB
# =============================================================================
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.togglemaster_analytics.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.togglemaster_analytics.arn
}

# =============================================================================
# Outputs - LabRole
# =============================================================================
output "lab_role_arn" {
  description = "LabRole ARN used by EKS cluster and node groups"
  value       = data.aws_iam_role.lab_role.arn
}
