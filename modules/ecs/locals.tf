locals {
  task_definition_template = {
    log_group                  = aws_cloudwatch_log_group.logs.name,
    aws_region                 = data.aws_region.current.name
    ecr_laravel_repository_uri = var.ecr.aws_ecr_repository_laravel.repository_url
    ecr_nginx_repository_uri   = var.ecr.aws_ecr_repository_laravel.repository_url
    env_vars = {
      LOG_CHANNEL = "stderr"
      APP_DEBUG   = true
      APP_URL     = "http://${aws_alb.main.dns_name}"

      DB_CONNECTION = "mysql"
      DB_HOST       = var.aurora.endpoint
      DB_PORT       = var.aurora.port
      DB_DATABASE   = var.aurora.database_name
      DB_USERNAME   = var.aurora.master_username
      DB_PASSWORD   = var.aurora.master_password

      AWS_BUCKET = var.s3.id
      AWS_URL    = var.s3.bucket_domain_name

      QUEUE_CONNECTION = "sqs"
      SQS_PREFIX       = "https://sqs.${var.region}.amazonaws.com/${var.account_id}"
      SQS_QUEUE        = var.sqs.name

      AWS_DEFAULT_REGION = data.aws_region.current.name

      CACHE_DRIVER   = "redis"
      SESSION_DRIVER = "redis"
      REDIS_CLIENT   = "phpredis"

      REDIS_HOST = var.elasticache.cache_nodes[0].address
      REDIS_PORT = var.elasticache.cache_nodes[0].port
    }
  }
}