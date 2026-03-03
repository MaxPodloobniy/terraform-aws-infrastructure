output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.this.key_name
}