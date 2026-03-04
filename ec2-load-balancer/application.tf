locals {
  template_name = "${var.prefix}-template"
  asg_name      = "${var.prefix}-asg"
  alb_name      = "${var.prefix}-loadbalancer"
  ec2_sg_name   = "${var.prefix}-ec2_sg"
  http_sg_name  = "${var.prefix}-http_sg"
  lb_sg_name    = "${var.prefix}-sglb"
  profile_name  = "${var.prefix}-instance_profile"
}

# ──────────────────────────────────────────────
# Data Sources — existing resources
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

data "aws_security_group" "ec2_sg" {
  name   = local.ec2_sg_name
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "http_sg" {
  name   = local.http_sg_name
  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "lb_sg" {
  name   = local.lb_sg_name
  vpc_id = data.aws_vpc.main.id
}

# ──────────────────────────────────────────────
# Launch Template
# ──────────────────────────────────────────────
resource "aws_launch_template" "this" {
  name          = local.template_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [data.aws_security_group.ec2_sg.id, data.aws_security_group.http_sg.id]
  }

  iam_instance_profile {
    name = local.profile_name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y aws-cli httpd jq

systemctl enable httpd
systemctl start httpd

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

cat > /var/www/html/index.html <<HTMLEOF
This message was generated on instance $INSTANCE_ID with the following IP: $PRIVATE_IP
HTMLEOF
EOF
  )

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
# Auto Scaling Group
# ──────────────────────────────────────────────
resource "aws_autoscaling_group" "this" {
  name                = local.asg_name
  desired_capacity    = 2
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
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

# ──────────────────────────────────────────────
# Application Load Balancer
# ──────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.prefix}-tg"
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

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}