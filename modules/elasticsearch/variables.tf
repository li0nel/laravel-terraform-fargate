variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "stack_name" {
  type = string
}

variable "aws_iam_role" {
  type = object({
    arn = string
  })
}
