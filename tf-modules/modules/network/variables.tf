variable "prefix" {
  description = "Resource name prefix"
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