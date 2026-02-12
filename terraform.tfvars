# =============================================================================
# General
# =============================================================================
region          = "us-east-1"
tag_environment = "production"
tag_ambiente    = "terraform-prod"

# =============================================================================
# VPC
# =============================================================================
vpc_name       = "ToggleMaster-production"
vpc_cidr_block = "10.0.0.0/20"
# Configuração de Rede Dinâmica
max_availability_zones = 2
subnet_newbits         = 4

# Estratégia de NAT Gateway
enable_nat_gateway = true
single_nat_gateway = false

enable_kubernetes_tags = true

# =============================================================================
# EC2 VPN (Pritunl)
# =============================================================================
instance_name           = "Pritunl_VPN_prod"
ami_id                  = "ami-096ea6a12ea24a797"
instance_type           = "t4g.micro"
vpn_volume_size         = 8
vpn_instance_profile    = "LabInstanceProfile"
vpn_associate_public_ip = true
create_eip = true

# =============================================================================
# Security Groups - Names & Descriptions
# =============================================================================
pritunl_sg_name        = "Pritunl_VPN-tf"
pritunl_sg_description = "Security group for EC2 instance running Pritunl VPN"

eks_workers_sg_name        = "eks-ToggleMaster-prd-workers"
eks_workers_sg_description = "Security group for EKS worker nodes"

togglemaster_sg_name        = "ToggleMaster-sg"
togglemaster_sg_description = "Security group for ToggleMaster - public HTTP and HTTPS"

auth_service_sg_name        = "auth-service"
auth_service_sg_description = "Security group for auth-service - PostgreSQL from EKS workers"

flag_service_sg_name        = "flag-service"
flag_service_sg_description = "Security group for flag_service - PostgreSQL from EKS workers"

targeting_service_sg_name        = "targeting-service"
targeting_service_sg_description = "Security group for targeting-service - PostgreSQL from EKS workers"

redis_sg_name        = "togglemaster-redis"
redis_sg_description = "Security group for Redis - access from EKS workers"

# =============================================================================
# Security Groups - Common Values
# =============================================================================
default_ipv4_cidr = "0.0.0.0/0"
default_ipv6_cidr = "::/0"
all_protocols     = "-1"

# =============================================================================
# Security Groups - Pritunl Ingress Rules
# =============================================================================
pritunl_ingress_ports = [
  {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    description = "Allow HTTP"
  },
  {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    description = "Allow HTTPS"
  },
  {
    from_port   = 5050
    to_port     = 5050
    ip_protocol = "udp"
    description = "Allow VPN UDP"
  }
]

# =============================================================================
# Security Groups - ToggleMaster Ingress Rules
# =============================================================================
togglemaster_ingress_ports = [
  {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    description = "Allow HTTP"
  },
  {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    description = "Allow HTTPS"
  }
]

# =============================================================================
# Security Groups - EKS Workers Ingress Descriptions
# =============================================================================
eks_workers_sg_rules = {
  from_pritunl      = "All traffic from Pritunl VPN"
  from_self         = "All traffic from self (EKS workers)"
  from_togglemaster = "All traffic from ToggleMaster SG"
  from_vpc_cidr     = "All traffic from VPC CIDR"
}

# =============================================================================
# Security Groups - Auth Service (PostgreSQL)
# =============================================================================
auth_service_port             = 5432
auth_service_protocol         = "tcp"
auth_service_rule_description = "Allow PostgreSQL from EKS workers"

# =============================================================================
# Security Groups - Flag Service (PostgreSQL)
# =============================================================================
flag_service_port             = 5432
flag_service_protocol         = "tcp"
flag_service_rule_description = "Allow PostgreSQL from EKS workers"
# =============================================================================
# Security Groups - Targeting Service (PostgreSQL)
# =============================================================================
targeting_service_port             = 5432
targeting_service_protocol         = "tcp"
targeting_service_rule_description = "Allow PostgreSQL from EKS workers"
# =============================================================================
# Security Groups - Redis
# =============================================================================
redis_port             = 6379
redis_protocol         = "tcp"
redis_rule_description = "Allow Redis from EKS workers"

# =============================================================================
# Launch Template
# =============================================================================
launch_template_name                   = "lt-togglemaster-prod"
launch_template_instance_type          = "t3.medium"
launch_template_update_default_version = true
launch_template_device_name            = "/dev/xvda"
launch_template_volume_size            = 60
launch_template_volume_type            = "gp3"
launch_template_volume_iops            = 3000
launch_template_delete_on_termination  = true
launch_template_encrypted              = true
launch_template_ebs_optimized          = true
launch_template_worker_tag             = "ToggleMaster-prd-workers"
launch_template_tag_resource_types     = ["instance", "volume"]

launch_template_metadata = {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_user_agent_restriction = 2
  http_put_response_hop_limit = 7
  instance_metadata_tags      = "enabled"
}

# =============================================================================
# EKS Cluster
# =============================================================================
cluster_name      = "ToggleMaster"
cluster_version   = "1.34"
service_ipv4_cidr = "10.43.0.0/16"
ip_family         = "ipv4"

enabled_cluster_log_types = ["api", "audit"]
support_type              = "EXTENDED"
deletion_protection       = true

endpoint_private_access = true
endpoint_public_access  = false

cluster_tags = {
  Environment = "production"
  Name        = "ToggleMaster"
}

authentication_mode                         = "API_AND_CONFIG_MAP"
bootstrap_cluster_creator_admin_permissions = true

# =============================================================================
# Node Groups
# =============================================================================
nodegroup_max_unavailable = 1

nodegroup_az_mapping = {
  "ToggleMaster-prd-private-1a-01" = 0
  "ToggleMaster-prd-private-1b-01" = 1
}

nodegroups = {
  "ToggleMaster-prd-private-1a-01" = {
    scaling_min     = 1
    scaling_max     = 4
    scaling_desired = 1
    ami_type        = "AL2023_x86_64_STANDARD"
    capacity_type   = "ON_DEMAND"
    instance_types  = []
    version         = "1.34"
    release_version = "1.34.2-20260129"
    labels = {
      "cattle.io/cluster-agent" = "true"
    }
    tags = {}
  }
  "ToggleMaster-prd-private-1b-01" = {
    scaling_min     = 1
    scaling_max     = 4
    scaling_desired = 1
    ami_type        = "AL2023_x86_64_STANDARD"
    capacity_type   = "ON_DEMAND"
    instance_types  = []
    version         = "1.34"
    release_version = "1.34.2-20260129"
    labels = {
      "cattle.io/cluster-agent" = "true"
    }
    tags = {}
  }
}

# =============================================================================
# SQS
# =============================================================================
sqs_queue_name         = "togglemaster-events"
sqs_visibility_timeout = 300
sqs_message_retention  = 345600
sqs_receive_wait_time  = 20

# =============================================================================
# RDS Database Configuration
# =============================================================================
db_name_auth            = "authdb"
db_name_flag            = "flagdb"
db_name_targeting       = "targetingdb"
db_identifier           = "auth-service"
db_identifier_flag      = "flag-service"
db_identifier_targeting = "targeting-service"
# Especificações da Instância (Academy / Free Tier Friendly)
db_engine         = "postgres"
db_engine_version = "18.1"
db_instance_class = "db.t3.micro"
db_username       = "postgres"

# Gerenciamento de Senha
manage_master_user_password = true

# Configurações de Storage
db_allocated_storage     = 20
db_max_allocated_storage = 100
db_storage_type          = "gp3"
db_storage_encrypted     = true

# Alta Disponibilidade e Backup
db_multi_az                = false
db_backup_retention_period = 0
db_skip_final_snapshot     = true
db_deletion_protection     = false

# =============================================================================
# DynamoDB
# =============================================================================
dynamodb_table_name   = "ToggleMasterAnalytics"
dynamodb_billing_mode = "PAY_PER_REQUEST"
dynamodb_hash_key     = "event_id"

dynamodb_attributes = [
  {
    name = "event_id"
    type = "S"
  }
]

# =============================================================================
# Fargate, Access Entries, Pod Identity
# =============================================================================
fargate_profiles          = {}
access_entries            = {}
pod_identity_associations = {}

# =============================================================================
# Addons
# =============================================================================
addons = {
  coredns = {
    addon_version            = "v1.13.2-eksbuild.1"
    configuration_values     = null
    resolve_conflicts        = "OVERWRITE"
    service_account_role_arn = null
    tags                     = {}
  }
  eks-pod-identity-agent = {
    addon_version            = "v1.3.10-eksbuild.2"
    configuration_values     = null
    resolve_conflicts        = "OVERWRITE"
    service_account_role_arn = null
    tags                     = {}
  }
  kube-proxy = {
    addon_version            = "v1.34.3-eksbuild.2"
    configuration_values     = null
    resolve_conflicts        = "OVERWRITE"
    service_account_role_arn = null
    tags                     = {}
  }
  vpc-cni = {
    addon_version            = "v1.21.1-eksbuild.3"
    configuration_values     = null
    resolve_conflicts        = "OVERWRITE"
    service_account_role_arn = null
    tags                     = {}
  }
}
