# =============================================================================
# Security Group: EKS Workers
# =============================================================================
resource "aws_security_group" "eks_workers" {
  # checkov:skip=CKV2_AWS_5 reason: "SG will be attached externally"
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
