output "vpc_id" {
  description = "The unique identifier of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block associated with the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "A set of IDs for all public subnets"
  value       = toset([for s in aws_subnet.public : s.id])
}

output "public_subnet_cidr_block" {
  description = "A set of CIDR blocks for all public subnets"
  value       = toset([for s in aws_subnet.public : s.cidr_block])
}

output "public_subnet_availability_zone" {
  description = "A set of availability zones for all public subnets"
  value       = toset([for s in aws_subnet.public : s.availability_zone])
}

output "internet_gateway_id" {
  description = "The unique identifier of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "routing_table_id" {
  description = "The unique identifier of the routing table"
  value       = aws_route_table.public.id
}