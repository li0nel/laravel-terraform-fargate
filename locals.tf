locals {
  stack_name = terraform.workspace == "default" ? var.project_name : join("-", [var.project_name, replace(terraform.workspace, "/[^[:alnum:]]/", "")])
  # hostname   = var.subdomain == "" ? var.domain : join(".", [var.subdomain, var.domain])
}
