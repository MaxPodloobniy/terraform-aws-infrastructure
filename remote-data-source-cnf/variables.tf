variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "project_id" {
  description = "Project identifier for tagging"
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket name for remote state"
  type        = string
}

variable "state_key" {
  description = "S3 key path for remote state file"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}