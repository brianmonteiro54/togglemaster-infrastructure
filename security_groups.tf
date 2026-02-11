# =============================================================================
# Security Group: Pritunl VPN (EC2)
# =============================================================================
resource "aws_security_group" "pritunl_vpn" {
  name        = var.pritunl_sg_name
  description = var.pritunl_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = var.tag_environment
    Ambiente    = var.tag_ambiente
    Name        = var.pritunl_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "pritunl_ingress" {
  count = length(var.pritunl_ingress_ports)

  description       = var.pritunl_ingress_ports[count.index].description
  security_group_id = aws_security_group.pritunl_vpn.id
  cidr_ipv4         = var.default_ipv4_cidr
  from_port         = var.pritunl_ingress_ports[count.index].from_port
  to_port           = var.pritunl_ingress_ports[count.index].to_port
  ip_protocol       = var.pritunl_ingress_ports[count.index].ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "pritunl_egress_all" {
  security_group_id = aws_security_group.pritunl_vpn.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}

# =============================================================================
# Security Group: EKS Workers
# =============================================================================
resource "aws_security_group" "eks_workers" {
  name        = var.eks_workers_sg_name
  description = var.eks_workers_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.eks_workers_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_pritunl" {
  description                  = var.eks_workers_sg_rules.from_pritunl
  security_group_id            = aws_security_group.eks_workers.id
  referenced_security_group_id = aws_security_group.pritunl_vpn.id
  ip_protocol                  = var.all_protocols
}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_self" {
  description                  = var.eks_workers_sg_rules.from_self
  security_group_id            = aws_security_group.eks_workers.id
  referenced_security_group_id = aws_security_group.eks_workers.id
  ip_protocol                  = var.all_protocols
}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_togglemaster_sg" {
  description                  = var.eks_workers_sg_rules.from_togglemaster
  security_group_id            = aws_security_group.eks_workers.id
  referenced_security_group_id = aws_security_group.togglemaster_sg.id
  ip_protocol                  = var.all_protocols
}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_vpc_cidr" {
  description       = var.eks_workers_sg_rules.from_vpc_cidr
  security_group_id = aws_security_group.eks_workers.id
  cidr_ipv4         = var.vpc_cidr_block
  ip_protocol       = var.all_protocols
}

resource "aws_vpc_security_group_egress_rule" "eks_workers_egress_all" {
  security_group_id = aws_security_group.eks_workers.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}

# =============================================================================
# Security Group: ToggleMaster (HTTP/HTTPS public)
# =============================================================================
resource "aws_security_group" "togglemaster_sg" {
  name        = var.togglemaster_sg_name
  description = var.togglemaster_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.togglemaster_sg_name
  })
}

# IPv4 rules
resource "aws_vpc_security_group_ingress_rule" "togglemaster_ingress_ipv4" {
  count = length(var.togglemaster_ingress_ports)

  description       = "${var.togglemaster_ingress_ports[count.index].description} IPv4"
  security_group_id = aws_security_group.togglemaster_sg.id
  cidr_ipv4         = var.default_ipv4_cidr
  from_port         = var.togglemaster_ingress_ports[count.index].from_port
  to_port           = var.togglemaster_ingress_ports[count.index].to_port
  ip_protocol       = var.togglemaster_ingress_ports[count.index].ip_protocol
}

# IPv6 rules (same ports)
resource "aws_vpc_security_group_ingress_rule" "togglemaster_ingress_ipv6" {
  count = length(var.togglemaster_ingress_ports)

  description       = "${var.togglemaster_ingress_ports[count.index].description} IPv6"
  security_group_id = aws_security_group.togglemaster_sg.id
  cidr_ipv6         = var.default_ipv6_cidr
  from_port         = var.togglemaster_ingress_ports[count.index].from_port
  to_port           = var.togglemaster_ingress_ports[count.index].to_port
  ip_protocol       = var.togglemaster_ingress_ports[count.index].ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "togglemaster_egress_all" {
  security_group_id = aws_security_group.togglemaster_sg.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}

# =============================================================================
# Security Group: auth-service (PostgreSQL)
# =============================================================================
resource "aws_security_group" "auth_service" {
  name        = var.auth_service_sg_name
  description = var.auth_service_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.auth_service_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "auth_service_postgres" {
  description                  = var.auth_service_rule_description
  security_group_id            = aws_security_group.auth_service.id
  referenced_security_group_id = aws_security_group.eks_workers.id
  from_port                    = var.auth_service_port
  ip_protocol                  = var.auth_service_protocol
  to_port                      = var.auth_service_port
}

resource "aws_vpc_security_group_egress_rule" "auth_service_egress_all" {
  security_group_id = aws_security_group.auth_service.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}

# =============================================================================
# Security Group: flag-service (PostgreSQL)
# =============================================================================
resource "aws_security_group" "flag_service" {
  name        = var.flag_service_sg_name
  description = var.flag_service_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.flag_service_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "flag_service_postgres" {
  description                  = var.flag_service_rule_description
  security_group_id            = aws_security_group.flag_service.id
  referenced_security_group_id = aws_security_group.eks_workers.id
  from_port                    = var.flag_service_port
  ip_protocol                  = var.flag_service_protocol
  to_port                      = var.flag_service_port
}

resource "aws_vpc_security_group_egress_rule" "flag_service_egress_all" {
  security_group_id = aws_security_group.flag_service.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}

# =============================================================================
# Security Group: auth-service (PostgreSQL)
# =============================================================================
resource "aws_security_group" "targeting_service" {
  name        = var.targeting_service_sg_name
  description = var.targeting_service_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.targeting_service_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "targeting_service_postgres" {
  description                  = var.targeting_service_rule_description
  security_group_id            = aws_security_group.targeting_service.id
  referenced_security_group_id = aws_security_group.eks_workers.id
  from_port                    = var.targeting_service_port
  ip_protocol                  = var.targeting_service_protocol
  to_port                      = var.targeting_service_port
}

resource "aws_vpc_security_group_egress_rule" "targeting_service_egress_all" {
  security_group_id = aws_security_group.targeting_service.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}


# =============================================================================
# Security Group: Redis
# =============================================================================
resource "aws_security_group" "togglemaster_redis" {
  name        = var.redis_sg_name
  description = var.redis_sg_description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.cluster_tags, {
    Name = var.redis_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "togglemaster_redis_ingress" {
  description                  = var.redis_rule_description
  security_group_id            = aws_security_group.togglemaster_redis.id
  referenced_security_group_id = aws_security_group.eks_workers.id
  from_port                    = var.redis_port
  ip_protocol                  = var.redis_protocol
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_egress_rule" "togglemaster_redis_egress_all" {
  security_group_id = aws_security_group.togglemaster_redis.id
  cidr_ipv4         = var.default_ipv4_cidr
  ip_protocol       = var.all_protocols
}
