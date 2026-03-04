locals {
  group_name    = "${var.prefix}-iam-group"
  policy_name   = "${var.prefix}-iam-policy"
  role_name     = "${var.prefix}-iam-role"
  profile_name  = "${var.prefix}-iam-instance-profile"
}

# ──────────────────────────────────────────────
# IAM Group
# ──────────────────────────────────────────────
resource "aws_iam_group" "this" {
  name = local.group_name
}

# ──────────────────────────────────────────────
# IAM Policy (S3 write access)
# ──────────────────────────────────────────────
resource "aws_iam_policy" "this" {
  name   = local.policy_name
  policy = templatefile("policy.json", {
    bucket_name = var.bucket_name
  })

  tags = {
    Project = var.prefix
  }
}

# ──────────────────────────────────────────────
# IAM Role (assumable by EC2)
# ──────────────────────────────────────────────
resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.prefix
  }
}

# ──────────────────────────────────────────────
# Attach Policy to Role
# ──────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# ──────────────────────────────────────────────
# Instance Profile
# ──────────────────────────────────────────────
resource "aws_iam_instance_profile" "this" {
  name = local.profile_name
  role = aws_iam_role.this.name

  tags = {
    Project = var.prefix
  }
}