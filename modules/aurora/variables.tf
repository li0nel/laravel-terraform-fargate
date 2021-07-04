variable "stack_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "port" {
  type    = number
  default = 3306
}
