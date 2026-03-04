output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "blue_asg_name" {
  description = "Name of the Blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}

output "green_asg_name" {
  description = "Name of the Green Auto Scaling Group"
  value       = aws_autoscaling_group.green.name
}