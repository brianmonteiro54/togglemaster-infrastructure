# =============================================================================
# General Variables
# =============================================================================
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "tag_environment" {
  description = "Environment tag"
  type        = string
}

variable "tag_ambiente" {
  description = "IAC tag"
  type        = string
}

# =============================================================================
# VPC Variables
# =============================================================================
variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (2)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (2)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "public_subnet_map_public_ip" {
  description = "Auto-assign public IP on launch for public subnets"
  type        = bool
}

variable "igw_name" {
  type = string
}

variable "public_subnet_names" {
  type = list(string)
}

variable "private_subnet_names" {
  type = list(string)
}

variable "public_rt_name" {
  type = string
}

variable "private_rt_names" {
  type = list(string)
}

variable "nat_gateway_names" {
  type = list(string)
}

variable "nat_eip_names" {
  type = list(string)
}

# =============================================================================
# EC2 VPN (Pritunl) Variables
# =============================================================================
variable "instance_name" {
  description = "EC2 instance name for Pritunl VPN"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 VPN instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpn_volume_size" {
  description = "Root volume size in GB for VPN EC2"
  type        = number
}

variable "vpn_instance_profile" {
  description = "IAM Instance Profile name for VPN EC2"
  type        = string
}

variable "vpn_associate_public_ip" {
  description = "Associate public IP to VPN EC2 instance"
  type        = bool
}

# =============================================================================
# Security Group Variables
# =============================================================================
variable "pritunl_sg_name" {
  description = "Name of the Pritunl VPN security group"
  type        = string
}

variable "pritunl_sg_description" {
  description = "Description of the Pritunl VPN security group"
  type        = string
}

variable "eks_workers_sg_name" {
  description = "Name of the EKS workers security group"
  type        = string
}

variable "eks_workers_sg_description" {
  description = "Description of the EKS workers security group"
  type        = string
}

variable "togglemaster_sg_name" {
  description = "Name of the ToggleMaster security group"
  type        = string
}

variable "togglemaster_sg_description" {
  description = "Description of the ToggleMaster security group"
  type        = string
}

variable "auth_service_sg_name" {
  description = "Name of the auth-service security group"
  type        = string
}

variable "auth_service_sg_description" {
  description = "Description of the auth-service security group"
  type        = string
}

variable "redis_sg_name" {
  description = "Name of the Redis security group"
  type        = string
}

variable "redis_sg_description" {
  description = "Description of the Redis security group"
  type        = string
}

variable "default_ipv4_cidr" {
  description = "Default IPv4 CIDR for open ingress/egress (e.g. 0.0.0.0/0)"
  type        = string
}

variable "default_ipv6_cidr" {
  description = "Default IPv6 CIDR for open ingress/egress (e.g. ::/0)"
  type        = string
}

variable "all_protocols" {
  description = "Value for all protocols in security group rules"
  type        = string
}

variable "pritunl_ingress_ports" {
  description = "Ingress ports for Pritunl VPN"
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    description = string
  }))
}

variable "togglemaster_ingress_ports" {
  description = "Ingress ports for ToggleMaster SG (HTTP/HTTPS)"
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    description = string
  }))
}

variable "eks_workers_sg_rules" {
  description = "Descriptions for EKS workers SG ingress rules"
  type = object({
    from_pritunl     = string
    from_self        = string
    from_togglemaster = string
    from_vpc_cidr    = string
  })
}

variable "auth_service_port" {
  description = "PostgreSQL port for auth-service"
  type        = number
}

variable "auth_service_protocol" {
  description = "Protocol for auth-service ingress rule"
  type        = string
}

variable "auth_service_rule_description" {
  description = "Description for auth-service ingress rule"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = number
}

variable "redis_protocol" {
  description = "Protocol for Redis ingress rule"
  type        = string
}

variable "redis_rule_description" {
  description = "Description for Redis ingress rule"
  type        = string
}

# =============================================================================
# Launch Template Variables
# =============================================================================
variable "launch_template_name" {
  description = "Name of the EKS workers launch template"
  type        = string
}

variable "launch_template_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
}

variable "launch_template_update_default_version" {
  description = "Update default version on each update"
  type        = bool
}

variable "launch_template_volume_size" {
  description = "EBS volume size in GB for EKS workers"
  type        = number
}

variable "launch_template_volume_type" {
  description = "EBS volume type for EKS workers"
  type        = string
}

variable "launch_template_volume_iops" {
  description = "IOPS for EKS worker EBS volume"
  type        = number
}

variable "launch_template_device_name" {
  description = "Device name for the EBS volume"
  type        = string
}

variable "launch_template_delete_on_termination" {
  description = "Delete EBS volume on instance termination"
  type        = bool
}

variable "launch_template_encrypted" {
  description = "Encrypt the EBS volume"
  type        = bool
}

variable "launch_template_ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
}

variable "launch_template_metadata" {
  description = "Metadata options for the launch template"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
}

variable "launch_template_worker_tag" {
  description = "Name tag for EKS worker instances and volumes"
  type        = string
}

variable "launch_template_tag_resource_types" {
  description = "Resource types for tag specifications"
  type        = list(string)
}

# =============================================================================
# EKS Cluster Variables
# =============================================================================


variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "Service CIDR block for Kubernetes services"
  type        = string
}

variable "ip_family" {
  description = "IP family for Kubernetes networking (ipv4 or ipv6)"
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = []
}

variable "support_type" {
  description = "Support type for the cluster (STANDARD or EXTENDED)"
  type        = string
  default     = "STANDARD"
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

variable "cluster_tags" {
  description = "Additional tags for the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode (CONFIG_MAP, API, API_AND_CONFIG_MAP)"
  type        = string
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant admin permissions to cluster creator"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API endpoint"
  type        = bool
}

# =============================================================================
# Node Groups Variables
# =============================================================================
variable "nodegroups" {
  description = "Map of node groups to create"
  type = map(object({
    scaling_min     = number
    scaling_max     = number
    scaling_desired = number
    ami_type        = string
    capacity_type   = string
    instance_types  = list(string)
    version         = string
    release_version = string
    labels          = map(string)
    tags            = map(string)
  }))
  default = {}
}

variable "nodegroup_az_mapping" {
  description = "Map of nodegroup name to AZ index (0 = AZ-a, 1 = AZ-b)"
  type        = map(number)
  default     = {}
}

variable "nodegroup_max_unavailable" {
  description = "Max unavailable nodes during update"
  type        = number
}

# =============================================================================
# SQS Variables
# =============================================================================
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout in seconds"
  type        = number
}

variable "sqs_message_retention" {
  description = "Message retention period in seconds"
  type        = number
}

variable "sqs_receive_wait_time" {
  description = "Receive message wait time in seconds (long polling)"
  type        = number
}

variable "sqs_tags" {
  description = "Tags for the SQS queue"
  type        = map(string)
  default     = {}
}

# =============================================================================
# DynamoDB Variables
# =============================================================================
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
}

variable "dynamodb_hash_key" {
  description = "Hash key (partition key) attribute name"
  type        = string
}

variable "dynamodb_attributes" {
  description = "List of attribute definitions for the DynamoDB table"
  type = list(object({
    name = string
    type = string
  }))
}

variable "dynamodb_tags" {
  description = "Tags for the DynamoDB table"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Fargate Variables
# =============================================================================
variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  type = map(object({
    pod_execution_role_arn = string
    subnet_ids             = list(string)
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Access Entries Variables
# =============================================================================
variable "access_entries" {
  description = "Map of IAM access entries to create"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    type              = string
    user_name         = optional(string)
    policy_associations = optional(list(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Addons Variables
# =============================================================================
variable "addons" {
  description = "EKS add-ons configuration"
  type = map(object({
    addon_version            = string
    configuration_values     = optional(string, null)
    resolve_conflicts        = optional(string, "OVERWRITE")
    service_account_role_arn = optional(string, null)
    tags                     = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Pod Identity Variables
# =============================================================================
variable "pod_identity_associations" {
  description = "EKS Pod Identity Associations"
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
    tags            = optional(map(string), {})
  }))
  default = {}
}
