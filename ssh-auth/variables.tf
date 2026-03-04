variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "ssh_key" {
  description = "Provides custom public SSH key."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "Resource name prefix for all resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}