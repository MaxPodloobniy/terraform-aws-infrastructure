variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix for all resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "blue_weight" {
  description = "The traffic weight for the Blue Target Group. Specifies the percentage of traffic routed to the Blue environment."
  type        = number
  default     = 100
}

variable "green_weight" {
  description = "The traffic weight for the Green Target Group. Specifies the percentage of traffic routed to the Green environment."
  type        = number
  default     = 0
}