# ──────────────────────────────────────────────
# Data Sources
# ──────────────────────────────────────────────
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-bgxc7tqb-vpc"]
  }
}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-bgxc7tqb-sg"]
  }
  vpc_id = data.aws_vpc.main.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ──────────────────────────────────────────────
# EC2 Instance
# ──────────────────────────────────────────────
resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [data.aws_security_group.main.id]
  subnet_id              = data.aws_subnets.public.ids[0]

  tags = {
    Name    = "cmtr-bgxc7tqb-ec2"
    Project = "epam-tf-lab"
    ID      = "cmtr-bgxc7tqb"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}