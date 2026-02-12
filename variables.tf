# =============================================================================
# General & VPC
# =============================================================================
variable "region" {
  description = "AWS region where all resources will be deployed."
  type        = string
}

variable "tag_environment" {
  description = "Environment tag applied to all resources (e.g., dev, staging, prod)."
  type        = string
}

variable "tag_ambiente" {
  description = "Additional environment tag used for resource identification."
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution support in the VPC."
  type        = bool
  default     = true
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones to use."
  type        = number
}

variable "subnet_newbits" {
  description = "Number of additional bits to create subnets from the VPC CIDR."
  type        = number
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways."
  type        = bool
}

variable "single_nat_gateway" {
  description = "Whether to use a single shared NAT Gateway."
  type        = bool
}

variable "enable_kubernetes_tags" {
  description = "Whether to apply Kubernetes-specific subnet tags."
  type        = bool
}


# =============================================================================
# EKS Cluster & Node Groups
# =============================================================================
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes service IP addresses."
  type        = string
}

variable "ip_family" {
  description = "IP family for the cluster (ipv4 or ipv6)."
  type        = string
}

variable "support_type" {
  description = "EKS support type (e.g., STANDARD or EXTENDED)."
  type        = string
}

variable "deletion_protection" {
  description = "Enable deletion protection for the EKS cluster."
  type        = bool
}

variable "cluster_tags" {
  description = "Additional tags applied to the EKS cluster."
  type        = map(string)
}

variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster."
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS API server."
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS API server."
  type        = bool
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant cluster creator admin permissions during bootstrap."
  type        = bool
}

variable "enabled_cluster_log_types" {
  description = "List of EKS control plane logs to enable."
  type        = list(string)
}

variable "enable_secrets_encryption" {
  description = "Enable EKS secrets encryption using KMS"
  type        = bool
  default     = false
}

variable "create_kms_key" {
  description = "Create a new KMS key for EKS secrets encryption. If false and enable_secrets_encryption=true, provide cluster_kms_key_arn."
  type        = bool
  default     = true
}

variable "cluster_kms_key_arn" {
  description = "Existing KMS key ARN for EKS secrets encryption. Required when enable_secrets_encryption=true and create_kms_key=false."
  type        = string
  default     = null
}

# =============================================================================
# Launch Template
# =============================================================================
variable "launch_template_name" {
  description = "Name of the EC2 launch template used by EKS node groups."
  type        = string
}

variable "launch_template_instance_type" {
  description = "EC2 instance type used in the launch template."
  type        = string
}

variable "launch_template_update_default_version" {
  description = "Whether to update the default version of the launch template."
  type        = bool
}

variable "launch_template_volume_size" {
  description = "Size (in GB) of the root EBS volume."
  type        = number
}

variable "launch_template_volume_type" {
  description = "Type of EBS volume (e.g., gp3, gp2)."
  type        = string
}

variable "launch_template_volume_iops" {
  description = "Provisioned IOPS for the EBS volume (if applicable)."
  type        = number
}

variable "launch_template_device_name" {
  description = "Device name exposed to the EC2 instance."
  type        = string
}

variable "launch_template_delete_on_termination" {
  description = "Whether to delete the EBS volume when the instance is terminated."
  type        = bool
}

variable "launch_template_encrypted" {
  description = "Whether the EBS volume should be encrypted."
  type        = bool
}

variable "launch_template_ebs_optimized" {
  description = "Whether the instance is EBS-optimized."
  type        = bool
}

variable "launch_template_worker_tag" {
  description = "Tag applied to worker nodes created from the launch template."
  type        = string
}

variable "launch_template_tag_resource_types" {
  description = "List of resource types to tag in the launch template."
  type        = list(string)
}

variable "launch_template_metadata" {
  description = "Configuration block for EC2 instance metadata options."
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
}

# =============================================================================
# Node Groups & Others
# =============================================================================
variable "nodegroups" {
  description = "Configuration map for EKS managed node groups."
  type        = any
}

variable "nodegroup_az_mapping" {
  description = "Mapping of node groups to specific availability zones."
  type        = any
}

variable "nodegroup_max_unavailable" {
  description = "Maximum number of unavailable nodes during update."
  type        = number
}

variable "addons" {
  description = "Map of EKS add-ons and their configurations."
  type        = any
}

variable "fargate_profiles" {
  description = "Configuration map for EKS Fargate profiles."
  type        = any
}

variable "access_entries" {
  description = "IAM access entries for the EKS cluster."
  type        = any
}

variable "pod_identity_associations" {
  description = "Pod identity associations for IAM roles in EKS."
  type        = any
}


# =============================================================================
# EC2 VPN, SQS, DynamoDB & Security Groups
# =============================================================================
variable "instance_name" {
  description = "Name of the EC2 VPN instance."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 VPN server."
  type        = string
}

variable "create_eip" {
  description = "Create and associate Elastic IP"
  type        = bool
  default     = false
}

variable "vpn_volume_size" {
  description = "EBS volume size for the VPN instance."
  type        = number
}

variable "vpn_instance_profile" {
  description = "IAM instance profile attached to the VPN EC2 instance."
  type        = string
}

variable "vpn_associate_public_ip" {
  description = "Whether to associate a public IP to the VPN instance."
  type        = bool
}

variable "eks_workers_sg_name" {
  description = "Name of the EKS workers security group."
  type        = string
}

variable "eks_workers_sg_description" {
  description = "Description of the EKS workers security group."
  type        = string
}

variable "togglemaster_sg_name" {
  description = "Name of the ToggleMaster service security group."
  type        = string
}

variable "togglemaster_sg_description" {
  description = "Description of the ToggleMaster service security group."
  type        = string
}

variable "redis_sg_name" {
  description = "Name of the Redis security group."
  type        = string
}

variable "redis_sg_description" {
  description = "Description of the Redis security group."
  type        = string
}

variable "default_ipv4_cidr" {
  description = "Default IPv4 CIDR allowed in security group rules."
  type        = string
}

variable "default_ipv6_cidr" {
  description = "Default IPv6 CIDR allowed in security group rules."
  type        = string
}

variable "all_protocols" {
  description = "Protocol identifier representing all protocols (e.g., -1)."
  type        = string
}
variable "togglemaster_ingress_ports" {
  description = "List of ingress rules for the ToggleMaster service security group."
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    description = string
  }))
}

variable "eks_workers_sg_rules" {
  description = "Security group rule sources allowed to access EKS worker nodes."
  type = object({
    from_pritunl      = string
    from_self         = string
    from_togglemaster = string
    from_vpc_cidr     = string
  })
}



variable "redis_port" {
  description = "Port used by the Redis service."
  type        = number
}

variable "redis_protocol" {
  description = "Protocol used by the Redis service."
  type        = string
}

variable "redis_rule_description" {
  description = "Description for the Redis security group rule."
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue."
  type        = string
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout for the SQS queue (in seconds)."
  type        = number
}

variable "sqs_message_retention" {
  description = "Message retention period for the SQS queue (in seconds)."
  type        = number
}

variable "sqs_receive_wait_time" {
  description = "Receive wait time for long polling (in seconds)."
  type        = number
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
}

variable "dynamodb_hash_key" {
  description = "Primary hash key for the DynamoDB table."
  type        = string
}

variable "dynamodb_attributes" {
  description = "List of DynamoDB table attributes."
  type = list(object({
    name = string
    type = string
  }))
}


# =============================================================================
# RDS Variables
# =============================================================================
variable "db_name_auth" {
  description = "Database name for the Auth service."
  type        = string
}

variable "db_name_flag" {
  description = "Database name for the Flag service."
  type        = string
}

variable "db_name_targeting" {
  description = "Database name for the Targeting service."
  type        = string
}

variable "db_identifier" {
  description = "Unique identifier for the Auth RDS instance."
  type        = string
}

variable "db_identifier_flag" {
  description = "Unique identifier for the Flag RDS instance."
  type        = string
}

variable "db_identifier_targeting" {
  description = "Unique identifier for the Targeting RDS instance."
  type        = string
}

variable "db_engine" {
  description = "Database engine type (e.g., postgres, mysql)."
  type        = string
}

variable "db_engine_version" {
  description = "Version of the database engine."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
}

variable "manage_master_user_password" {
  description = "Whether AWS should manage the master user password."
  type        = bool
}

variable "db_allocated_storage" {
  description = "Allocated storage size in GB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum storage size for autoscaling (in GB)."
  type        = number
}

variable "db_storage_type" {
  description = "Storage type for RDS (e.g., gp3, io1)."
  type        = string
}

variable "db_storage_encrypted" {
  description = "Whether to enable storage encryption."
  type        = bool
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot before deletion."
  type        = bool
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the RDS instance."
  type        = bool
}
