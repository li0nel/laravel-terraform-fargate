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

variable "aurora_endpoint" {
  type = string
}

variable "aurora_port" {
  type = number
}

variable "aurora_db_name" {
  type = string
}

variable "aurora_db_username" {
  type = string
}

variable "aurora_master_password" {
  type = string
}

variable "ecr_laravel_repository_uri" {
  type = string
}

variable "ecr_nginx_repository_uri" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
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
