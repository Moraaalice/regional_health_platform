output "instance_id" {
  value = aws_instance.app.id
}

output "security_group_id" {
  value = aws_security_group.app.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
