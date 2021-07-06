variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "stack_name" {
  type = string
}

variable "security_group_ids" {
  type = list(any)
}

variable "aws_iam_role" {
  type = object({
    arn = string
  })
}
