module "vpc" {
  source = "github.com/brianmonteiro54/terraform-aws-vpc-network//modules/vpc?ref=main"

  tag_environment             = var.tag_environment
  tag_ambiente                = var.tag_ambiente
  cluster_name                = var.cluster_name
  vpc_name                    = var.vpc_name
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_subnet_cidrs        = var.private_subnet_cidrs
  availability_zones          = var.availability_zones
  public_subnet_map_public_ip = var.public_subnet_map_public_ip
  igw_name                    = var.igw_name
  public_subnet_names         = var.public_subnet_names
  private_subnet_names        = var.private_subnet_names
  public_rt_name              = var.public_rt_name
  private_rt_names            = var.private_rt_names
  nat_gateway_names           = var.nat_gateway_names
  nat_eip_names               = var.nat_eip_names
  default_ipv4_cidr           = var.default_ipv4_cidr
}