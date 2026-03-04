locals {
  ec2_name = "${var.prefix}-ec2"
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [var.sg_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name    = local.ec2_name
    Project = "epam-tf-lab"
    ID      = var.prefix
  }
}