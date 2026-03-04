locals {
  instance_name = "${var.project_id}-instance"
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [data.aws_security_group.main.id]

  tags = {
    Name      = local.instance_name
    Terraform = "true"
    Project   = var.project_id
  }
}