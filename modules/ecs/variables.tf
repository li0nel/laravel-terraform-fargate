variable "stack_name" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "role" {
  type = string
}

# variable "certificate_arn" {
#   type = string
# }

# variable "hostname" {
#   type = string
# }

variable "ecr_laravel_repository_uri" {
  type = string
}

variable "ecr_nginx_repository_uri" {
  type = string
}

variable "aws_s3_bucket" {
  type = object({
    id                 = string
    arn                = string
    bucket_domain_name = string
  })
}

variable "autoscaling_type" {
  type        = string
  description = "Either ALBRequestCountPerTarget, ECSServiceAverageMemoryUtilization, ECSServiceAverageCPUUtilization."
  default     = "ECSServiceAverageCPUUtilization"
}

variable "autoscaling_target" {
  type    = string
  default = 60
}

variable "autoscaling_max" {
  type    = number
  default = 5
}

variable "aws_rds_cluster" {
  type = object({
    endpoint        = string
    port            = number
    database_name   = string
    master_username = string
    master_password = string
  })
}

variable "aws_sqs_queue" {
  type = object({
    name = string
  })
}

variable "aws_elasticache_cluster" {
  type = object({
    cache_nodes = list(object({
      address = string
      port    = number
    }))
  })
}

