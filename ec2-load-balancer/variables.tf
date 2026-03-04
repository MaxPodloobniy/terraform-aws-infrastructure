variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix for all resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for launch template"
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
}