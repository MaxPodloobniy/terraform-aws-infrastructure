locals {
  ec2_name = "${var.prefix}-ec2"
  sg_name  = "${var.prefix}-sg"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = [local.sg_name]
  }
  vpc_id = data.aws_vpc.main.id
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [data.aws_security_group.main.id]
  subnet_id                   = data.aws_subnets.available.ids[0]
  associate_public_ip_address = true

  tags = {
    Name    = local.ec2_name
    Project = "epam-tf-lab"
    ID      = var.prefix
  }
}