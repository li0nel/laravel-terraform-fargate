output "aws_security_group" {
  value = aws_security_group.ecs_tasks
}

output "aws_alb" {
  value = aws_alb.main
}