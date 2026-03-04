variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "project_tag" {
  description = "Project tag value for resource tracking"
  type        = string
}