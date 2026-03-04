variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix for all resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the existing S3 bucket to grant access to"
  type        = string
}