variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "stack_name" {
  type = string
}
