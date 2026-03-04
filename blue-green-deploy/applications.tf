locals {
  lb_name             = "${var.prefix}-lb"
  blue_tg_name        = "${var.prefix}-blue-tg"
  green_tg_name       = "${var.prefix}-green-tg"
  blue_template_name  = "${var.prefix}-blue-template"
  green_template_name = "${var.prefix}-green-template"
  blue_asg_name       = "${var.prefix}-blue-asg"
  green_asg_name      = "${var.prefix}-green-asg"
  ssh_sg_name         = "${var.prefix}-sg-ssh"
  http_sg_name        = "${var.prefix}-sg-http"
  lb_sg_name          = "${var.prefix}-sg-lb"
}

# ──────────────────────────────────────────────
# Data Sources
# ──────────────────────────────────────────────
data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_security_group" "ssh" {
  name   = local.ssh_sg_name
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "http" {
  name   = local.http_sg_name
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "lb" {
  name   = local.lb_sg_name
  vpc_id = data.aws_vpc.main.id
}

# ──────────────────────────────────────────────
# Launch Templates
# ──────────────────────────────────────────────
resource "aws_launch_template" "blue" {
  name          = local.blue_template_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [data.aws_security_group.ssh.id, data.aws_security_group.http.id]
  }

  user_data = base64encode(file("start-blue.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Terraform = "true"
      Project   = var.prefix
    }
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_launch_template" "green" {
  name          = local.green_template_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [data.aws_security_group.ssh.id, data.aws_security_group.http.id]
  }

  user_data = base64encode(file("start-green.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Terraform = "true"
      Project   = var.prefix
    }
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

# ──────────────────────────────────────────────
# Target Groups
# ──────────────────────────────────────────────
resource "aws_lb_target_group" "blue" {
  name     = local.blue_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_lb_target_group" "green" {
  name     = local.green_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

# ──────────────────────────────────────────────
# Application Load Balancer
# ──────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.lb.id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }
    }
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

# ──────────────────────────────────────────────
# Auto Scaling Groups
# ──────────────────────────────────────────────
resource "aws_autoscaling_group" "blue" {
  name                = local.blue_asg_name
  desired_capacity    = 2
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.aws_subnets.public.ids
  target_group_arns   = [aws_lb_target_group.blue.arn]

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.prefix
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green" {
  name                = local.green_asg_name
  desired_capacity    = 2
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.aws_subnets.public.ids
  target_group_arns   = [aws_lb_target_group.green.arn]

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.prefix
    propagate_at_launch = true
  }
}