variable "prefix" {
  description = "Resource name prefix"
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

variable "subnet_ids" {
  description = "List of subnet IDs for ASG and ALB"
  type        = list(string)
}

variable "ssh_sg_id" {
  description = "ID of the SSH security group"
  type        = string
}

variable "http_sg_id" {
  description = "ID of the HTTP security group for instances"
  type        = string
}

variable "lb_sg_id" {
  description = "ID of the security group for the load balancer"
  type        = string
}