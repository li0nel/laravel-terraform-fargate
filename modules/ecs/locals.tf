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
      DB_HOST       = var.aws_rds_cluster.endpoint
      DB_PORT       = var.aws_rds_cluster.port
      DB_DATABASE   = var.aws_rds_cluster.database_name
      DB_USERNAME   = var.aws_rds_cluster.master_username
      DB_PASSWORD   = var.aws_rds_cluster.master_password
      AWS_BUCKET    = var.aws_s3_bucket.id
      AWS_URL       = var.aws_s3_bucket.bucket_domain_name
      QUEUE_CONNECTION = "sqs"
      SQS_PREFIX       = "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}"
      SQS_QUEUE        = var.aws_sqs_queue.name
      AWS_DEFAULT_REGION = data.aws_region.current.name
      CACHE_DRIVER   = "redis"
    #   SESSION_DRIVER = "redis"
      REDIS_CLIENT   = "phpredis"
      REDIS_HOST = var.aws_elasticache_cluster.cache_nodes[0].address
      REDIS_PORT = var.aws_elasticache_cluster.cache_nodes[0].port
    }
  }
}
