variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "domain" {
  type = string
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "b_route53_zone" {
  type    = bool
  default = false
}