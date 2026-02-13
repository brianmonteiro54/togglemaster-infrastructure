# =============================================================================
# Security Group: EKS Workers
# =============================================================================
resource "aws_security_group" "eks_workers" {
  name        = var.eks_workers_sg_name
  description = var.eks_workers_sg_description
  vpc_id      = module.vpc.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_pritunl" {
  description                  = var.eks_workers_sg_rules.from_pritunl
  security_group_id            = aws_security_group.eks_workers.id
  referenced_security_group_id = module.pritunl_vpn.security_group_id
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
  description       = "Allow all outbound traffic"
}

# =============================================================================
# Security Group: ToggleMaster (HTTP/HTTPS public)
# =============================================================================
resource "aws_security_group" "togglemaster_sg" {
  name        = var.togglemaster_sg_name
  description = var.togglemaster_sg_description
  vpc_id      = module.vpc.vpc_id
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
  description       = "Allow all outbound traffic"
}
