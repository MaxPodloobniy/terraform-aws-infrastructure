variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with name, CIDR block, and availability zone"
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "allowed_ip_range" {
  description = "List of IP address ranges for secure access"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}