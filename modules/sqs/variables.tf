variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "stack_name" {
  type = string
}

variable "security_group_ids" {
  type = list(any)
}
