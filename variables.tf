# =============================================================================
# General & VPC
# =============================================================================
variable "region" { type = string }
variable "tag_environment" { type = string }
variable "tag_ambiente" { type = string }
variable "vpc_name" { type = string }
variable "vpc_cidr_block" { type = string }

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "max_availability_zones" { type = number }
variable "subnet_newbits" { type = number }
variable "enable_nat_gateway" { type = bool }
variable "single_nat_gateway" { type = bool }
variable "enable_kubernetes_tags" { type = bool }

# =============================================================================
# EKS Cluster & Node Groups
# =============================================================================
variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "service_ipv4_cidr" { type = string }
variable "ip_family" { type = string }
variable "support_type" { type = string }
variable "deletion_protection" { type = bool }
variable "cluster_tags" { type = map(string) }
variable "authentication_mode" { type = string }
variable "endpoint_private_access" { type = bool }
variable "endpoint_public_access" { type = bool }
variable "bootstrap_cluster_creator_admin_permissions" { type = bool }
variable "enabled_cluster_log_types" { type = list(string) }
# =============================================================================
# Launch Template
# =============================================================================
variable "launch_template_name" { type = string }
variable "launch_template_instance_type" { type = string }
variable "launch_template_update_default_version" { type = bool }
variable "launch_template_volume_size" { type = number }
variable "launch_template_volume_type" { type = string }
variable "launch_template_volume_iops" { type = number }
variable "launch_template_device_name" { type = string }
variable "launch_template_delete_on_termination" { type = bool }
variable "launch_template_encrypted" { type = bool }
variable "launch_template_ebs_optimized" { type = bool }
variable "launch_template_worker_tag" { type = string }
variable "launch_template_tag_resource_types" { type = list(string) }
variable "launch_template_metadata" {
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
variable "nodegroups" { type = any }
variable "nodegroup_az_mapping" { type = any }
variable "nodegroup_max_unavailable" { type = number }
variable "addons" { type = any }
variable "fargate_profiles" { type = any }
variable "access_entries" { type = any }
variable "pod_identity_associations" { type = any }

# =============================================================================
# EC2 VPN, SQS, DynamoDB & Security Groups
# =============================================================================
variable "instance_name" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "vpn_volume_size" { type = number }
variable "vpn_instance_profile" { type = string }
variable "vpn_associate_public_ip" { type = bool }
variable "pritunl_sg_name" { type = string }
variable "pritunl_sg_description" { type = string }
variable "eks_workers_sg_name" { type = string }
variable "eks_workers_sg_description" { type = string }
variable "togglemaster_sg_name" { type = string }
variable "togglemaster_sg_description" { type = string }
variable "auth_service_sg_name" { type = string }
variable "auth_service_sg_description" { type = string }
variable "redis_sg_name" { type = string }
variable "redis_sg_description" { type = string }
variable "default_ipv4_cidr" { type = string }
variable "default_ipv6_cidr" { type = string }
variable "all_protocols" { type = string }

variable "pritunl_ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    description = string
  }))
}

variable "togglemaster_ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    description = string
  }))
}

variable "eks_workers_sg_rules" {
  type = object({
    from_pritunl      = string
    from_self         = string
    from_togglemaster = string
    from_vpc_cidr     = string
  })
}

variable "auth_service_port" { type = number }
variable "auth_service_protocol" { type = string }
variable "auth_service_rule_description" { type = string }
variable "flag_service_sg_name" { type = string }
variable "flag_service_sg_description" { type = string }
variable "flag_service_rule_description" { type = string }
variable "flag_service_port" { type = number }
variable "flag_service_protocol" { type = string }
variable "targeting_service_sg_name" { type = string }
variable "targeting_service_sg_description" { type = string }
variable "targeting_service_rule_description" { type = string }
variable "targeting_service_port" { type = number }
variable "targeting_service_protocol" { type = string }
variable "redis_port" { type = number }
variable "redis_protocol" { type = string }
variable "redis_rule_description" { type = string }
variable "sqs_queue_name" { type = string }
variable "sqs_visibility_timeout" { type = number }
variable "sqs_message_retention" { type = number }
variable "sqs_receive_wait_time" { type = number }
variable "dynamodb_table_name" { type = string }
variable "dynamodb_billing_mode" { type = string }
variable "dynamodb_hash_key" { type = string }
variable "dynamodb_attributes" {
  type = list(object({
    name = string
    type = string
  }))
}

# =============================================================================
# RDS Variables
# =============================================================================
variable "db_name_auth" { type = string }
variable "db_name_flag" { type = string }
variable "db_name_targeting" { type = string }
variable "db_identifier" { type = string }
variable "db_identifier_flag" { type = string }
variable "db_identifier_targeting" { type = string }
variable "db_engine" { type = string }
variable "db_engine_version" { type = string }
variable "db_instance_class" { type = string }
variable "db_username" { type = string }
variable "manage_master_user_password" { type = bool }
variable "db_allocated_storage" { type = number }
variable "db_max_allocated_storage" { type = number }
variable "db_storage_type" { type = string }
variable "db_storage_encrypted" { type = bool }
variable "db_multi_az" { type = bool }
variable "db_backup_retention_period" { type = number }
variable "db_skip_final_snapshot" { type = bool }
variable "db_deletion_protection" { type = bool }
