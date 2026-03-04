output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "vpc_id" {
  description = "ID of the discovered VPC"
  value       = data.aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the discovered subnet"
  value       = data.aws_subnet.public.id
}

output "ami_id" {
  description = "ID of the discovered AMI"
  value       = data.aws_ami.amazon_linux.id
}