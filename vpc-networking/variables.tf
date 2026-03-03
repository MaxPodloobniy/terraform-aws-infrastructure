variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with their name, CIDR block, and availability zone"
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "rt_name" {
  description = "Name of the public route table"
  type        = string
}
