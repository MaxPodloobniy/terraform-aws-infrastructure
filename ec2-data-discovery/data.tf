data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "public" {
  tags = {
    Name = var.public_subnet_name
  }
}

data "aws_security_group" "main" {
  tags = {
    Name = var.security_group_name
  }
  vpc_id = data.aws_vpc.main.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}