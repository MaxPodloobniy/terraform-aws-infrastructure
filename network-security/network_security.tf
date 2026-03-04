locals {
  ssh_sg_name          = "${var.prefix}-ssh-sg"
  public_http_sg_name  = "${var.prefix}-public-http-sg"
  private_http_sg_name = "${var.prefix}-private-http-sg"
}

# ──────────────────────────────────────────────
# Data: знаходимо мережеві інтерфейси інстансів
# ──────────────────────────────────────────────
data "aws_instance" "public" {
  instance_id = var.public_instance_id
}

data "aws_instance" "private" {
  instance_id = var.private_instance_id
}

# ──────────────────────────────────────────────
# SSH Security Group
# ──────────────────────────────────────────────
resource "aws_security_group" "ssh" {
  name   = local.ssh_sg_name
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_range
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.allowed_ip_range
  }

  tags = {
    Name    = local.ssh_sg_name
    Project = var.prefix
  }
}

# ──────────────────────────────────────────────
# Public HTTP Security Group
# ──────────────────────────────────────────────
resource "aws_security_group" "public_http" {
  name   = local.public_http_sg_name
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_range
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.allowed_ip_range
  }

  tags = {
    Name    = local.public_http_sg_name
    Project = var.prefix
  }
}

# ──────────────────────────────────────────────
# Private HTTP Security Group
# ──────────────────────────────────────────────
resource "aws_security_group" "private_http" {
  name   = local.private_http_sg_name
  vpc_id = var.vpc_id

  ingress {
    description              = "Allow HTTP from Public SG"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.public_http.id
  }

  ingress {
    description              = "Allow ICMP from Public SG"
    from_port                = -1
    to_port                  = -1
    protocol                 = "icmp"
    source_security_group_id = aws_security_group.public_http.id
  }

  tags = {
    Name    = local.private_http_sg_name
    Project = var.prefix
  }
}

# ──────────────────────────────────────────────
# Attach SGs to Public Instance
# ──────────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "public_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

resource "aws_network_interface_sg_attachment" "public_http" {
  security_group_id    = aws_security_group.public_http.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

# ──────────────────────────────────────────────
# Attach SGs to Private Instance
# ──────────────────────────────────────────────
resource "aws_network_interface_sg_attachment" "private_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.private.network_interface_id
}

resource "aws_network_interface_sg_attachment" "private_http" {
  security_group_id    = aws_security_group.private_http.id
  network_interface_id = data.aws_instance.private.network_interface_id
}