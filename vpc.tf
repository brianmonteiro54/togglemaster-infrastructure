module "vpc" {
  # checkov:skip=CKV_AWS_130:Public subnets intentionally map public IPs for ingress
  # checkov:skip=CKV2_AWS_11:VPC Flow Logs are managed or skipped for this environment
  # checkov:skip=CKV2_AWS_12:Default SG is restricted by AWS provider or manual config
  source = "git::https://github.com/brianmonteiro54/terraform-aws-vpc-network.git//modules/vpc?ref=8d9e89b240e4843d472192cf5e04339f7518832a"



  name        = var.vpc_name
  vpc_cidr    = var.vpc_cidr_block
  environment = var.tag_environment

  max_availability_zones = var.max_availability_zones
  subnet_newbits         = var.subnet_newbits

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_kubernetes_tags = var.enable_kubernetes_tags
  cluster_name           = var.cluster_name

  tags = {
    Ambiente    = var.tag_ambiente
    Environment = var.tag_environment
    ManagedBy   = "Terraform"
    Project     = "ToggleMaster"
  }
}
