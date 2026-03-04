variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP address ranges for secure access"
  type        = list(string)
}