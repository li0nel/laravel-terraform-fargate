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

# variable "s3_bucket_name" {
#   type = string
# }

# variable "s3_bucket_arn" {
#   type = string
# }

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

variable "s3" {
  type = object({
    id                 = string
    arn                = string
    bucket_domain_name = string
    website_endpoint   = string
  })
}

variable "sqs" {
  type = object({
    id   = string
    arn  = string
    name = string
  })
}

variable "elasticache" {
  type = object({
    cache_nodes = list(object({
      address = string
      port    = number
    }))
    id = string
  })
}

variable "aurora" {
  type = object({
    endpoint        = string
    port            = number
    database_name   = string
    master_username = string
    master_password = string
  })
}

variable "ecr" {
  type = object({
    aws_ecr_repository_laravel = object({
      repository_url = string
    })
    aws_ecr_repository_nginx = object({
      repository_url = string
    })
  })
}

variable "account_id" {
  type = string
}
