# =============================================================================
# EC2 VPN - Pritunl (Consumindo Módulo Customizado)
# =============================================================================

module "pritunl_vpn" {
  source = "github.com/brianmonteiro54/terraform-aws-ec2//modules/ec2?ref=7697a207824dba770c38caafe88b7fd080d60b03"

  # --- Identificação ---
  instance_name = var.instance_name
  environment   = var.tag_environment

  # --- Configuração da Instância ---
  ami_id        = var.ami_id
  instance_type = var.instance_type
  # O módulo já aceita o nome do profile ou cria um novo
  iam_instance_profile = var.vpn_instance_profile

  # Script de instalação do Docker/Pritunl
  user_data = file("ec2_userdata.sh")

  # --- Rede ---
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = var.vpn_associate_public_ip

  # --- Elastic IP (O módulo gerencia a criação e associação) ---
  create_eip = var.create_eip

  # --- Storage ---
  root_volume_size = var.vpn_volume_size
  root_volume_type = "gp3"

  enable_ebs_encryption = true
  create_kms_key        = false

  # --- Security Group (Configuração dinâmica via Módulo) ---
  create_security_group = true
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.default_ipv4_cidr]
      description = "Allow HTTP for Pritunl Web"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.default_ipv4_cidr]
      description = "Allow HTTPS for Pritunl Web"
    },
    {
      from_port   = 5050
      to_port     = 5050
      protocol    = "udp"
      cidr_blocks = [var.default_ipv4_cidr]
      description = "Allow Pritunl VPN UDP"
    }
  ]

  # --- Monitoramento ---
  enable_cloudwatch_alarms = true
  enable_auto_recovery     = true

}
