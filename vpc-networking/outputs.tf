output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Map of public subnet keys to their IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}
