# =============================================================================
# EC2 VPN - Pritunl
# =============================================================================

# Elastic IP for VPN
resource "aws_eip" "vpn_ec2_eip" {
  domain = "vpc"

  tags = {
    Name        = var.instance_name
    Environment = var.tag_environment
    Ambiente    = var.tag_ambiente
  }
}

# Associate Elastic IP to EC2 instance
resource "aws_eip_association" "vpn_ec2_eip_association" {
  instance_id   = aws_instance.vpn_ec2.id
  allocation_id = aws_eip.vpn_ec2_eip.id

  depends_on = [aws_instance.vpn_ec2]
}

# EC2 Instance for VPN
resource "aws_instance" "vpn_ec2" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = var.vpn_instance_profile
  user_data            = file("ec2_userdata.sh")

  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = var.vpn_associate_public_ip
  vpc_security_group_ids      = [aws_security_group.pritunl_vpn.id]

  root_block_device {
    volume_size = var.vpn_volume_size
  }

  tags = {
    Name        = var.instance_name
    Environment = var.tag_environment
  }
}
