resource "aws_launch_template" "this" {
  name          = "${var.prefix}-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [var.ssh_sg_id, var.http_sg_id]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd jq
systemctl enable httpd
systemctl start httpd

COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
COMPUTE_INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

cat > /var/www/html/index.html <<HTMLEOF
This message was generated on instance $COMPUTE_INSTANCE_ID with the following UUID $COMPUTE_MACHINE_UUID
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

resource "aws_autoscaling_group" "this" {
  name                = "${var.prefix}-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 2
  vpc_zone_identifier = var.subnet_ids

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

resource "aws_lb" "this" {
  name               = "${var.prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = var.subnet_ids

  tags = {
    Terraform = "true"
    Project   = var.prefix
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_launch_template.this.tags_all["Project"] != "" ? data.aws_subnet.first.vpc_id : ""

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

data "aws_subnet" "first" {
  id = var.subnet_ids[0]
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