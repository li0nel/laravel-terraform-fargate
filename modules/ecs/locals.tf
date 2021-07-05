locals {
  task_definition_template = {
    log_group                  = aws_cloudwatch_log_group.logs.name,
    aws_region                 = data.aws_region.current.name
    ecr_laravel_repository_uri = var.ecr_laravel_repository_uri
    ecr_nginx_repository_uri   = var.ecr_nginx_repository_uri
    env_vars = {
      LOG_CHANNEL   = "stderr"
      APP_DEBUG     = false
      APP_URL       = "http://${aws_alb.main.dns_name}"
      DB_CONNECTION = "mysql"
      DB_HOST       = var.aurora.endpoint
      DB_PORT       = var.aurora.port
      DB_DATABASE   = var.aurora.database_name
      DB_USERNAME   = var.aurora.master_username
      DB_PASSWORD   = var.aurora.master_password
      BUCKET_NAME   = var.s3_bucket_name
    }
  }
}
