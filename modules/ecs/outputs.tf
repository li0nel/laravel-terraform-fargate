output "ecs_alb_hostname" {
  value = aws_alb.main.dns_name
}

output "ecs_alb_zone_id" {
  value = aws_alb.main.zone_id
}

output "aws_security_group" {
  value = aws_security_group.ecs_tasks
}