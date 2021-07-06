resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.stack_name
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids = [
    aws_security_group.redis.id
  ]
}

resource "aws_security_group" "redis" {
  name   = "${var.stack_name}-redis"
  vpc_id = var.vpc_id

  ingress {
    from_port   = "6739"
    to_port     = "6739"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-${var.stack_name}"
  subnet_ids = var.subnet_ids
}

