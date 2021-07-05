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
      DB_HOST       = var.aurora_endpoint
      DB_PORT       = var.aurora_port
      DB_DATABASE   = var.aurora_db_name
      DB_USERNAME   = var.aurora_db_username
      DB_PASSWORD   = var.aurora_master_password
      BUCKET_NAME   = var.s3_bucket_name
    }
  }
} 
