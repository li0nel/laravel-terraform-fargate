output "laravel_repository_uri" {
  value = aws_ecr_repository.laravel.repository_url
}

output "nginx_repository_uri" {
  value = aws_ecr_repository.nginx.repository_url
}