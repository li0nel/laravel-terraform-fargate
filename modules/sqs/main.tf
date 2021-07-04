resource "aws_sqs_queue" "queue" {
    name = var.stack_name
}

resource "aws_vpc_endpoint" "sqs" {
  private_dns_enabled = true
  service_name        = join(".", ["com.amazonaws", data.aws_region.current.name, "sqs"])
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id

  security_group_ids = var.security_group_ids

  subnet_ids = var.private_subnet_ids
}

# resource "aws_vpc_endpoint_subnet_association" "sqs" {
#   for_each        = toset(var.private_subnet_ids)
#   subnet_id       = each.value
#   vpc_endpoint_id = aws_vpc_endpoint.sqs.id
# }

