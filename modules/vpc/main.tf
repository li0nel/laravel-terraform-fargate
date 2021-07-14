resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnets" {
  count             = local.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_rt_associations" {
  count          = local.az_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_routetable.id
}

resource "aws_eip" "eips" {
  count = var.b_nat_gateway == true ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.b_nat_gateway == true ? 1 : 0
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[0].id

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_subnet" "private_subnets" {
  count             = local.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + local.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route" {
  count                  = var.b_nat_gateway == true ? 1 : 0
  route_table_id         = aws_route_table.private_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private_routetable]
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_route_table_association" "private_rt_associations" {
  count          = local.az_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_routetable.id
}

# // Gateway VPC endpoint
# data "aws_vpc_endpoint_service" "s3" {
#   service = "s3"
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = aws_vpc.vpc.id
#   service_name = data.aws_vpc_endpoint_service.s3[0].service_name
# }

# resource "aws_vpc_endpoint_route_table_association" "s3" {
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
#   route_table_id  = aws_route_table.private_routetable.id
# }

# // Interface VPC endpoints
# data "aws_vpc_endpoint_service" "ecs" {
#   service = "ecs"
# }

# data "aws_vpc_endpoint_service" "ecr" {
#   service = "ecr"
# }

# resource "aws_security_group" "vpc_endpoint" {
#   name   = "vpc-endpoint-${var.stack_name}"
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     protocol        = "tcp"
#     from_port       = 0
#     to_port         = 0
#     cidr_blocks = aws_subnet.private_subnets.*.cidr_blocks
#   }

#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_vpc_endpoint" "ecs" {
#   count = length(data.aws_vpc_endpoint_service.ecs)

#   vpc_id       = aws_vpc.vpc.id
#   service_name = data.aws_vpc_endpoint_service.ecs.*.service_name[count.index]
#   vpc_endpoint_type = "Interface"
#   subnet_ids = aws_subnet.private_subnets.*.id
#   security_group_ids = [aws_security_group.vpc_endpoint.id]
#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ecr" {
#   count = length(data.aws_vpc_endpoint_service.ecr)

#   vpc_id       = aws_vpc.vpc.id
#   service_name = data.aws_vpc_endpoint_service.ecr.*.service_name[count.index]
#   vpc_endpoint_type = "Interface"
#   subnet_ids = aws_subnet.private_subnets.*.id
#   security_group_ids = [aws_security_group.vpc_endpoint.id]
#   private_dns_enabled = true
# }

# resource "aws_acm_certificate" "vpn_server" {
#   domain_name = "example-vpn.example.com"
#   validation_method = "DNS"

#   tags = local.global_tags

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "vpn_server" {
#   certificate_arn = aws_acm_certificate.vpn_server.arn

#   timeouts {
#     create = "1m"
#   }
# }

# resource "aws_acm_certificate" "vpn_client_root" {
#   private_key = file("certs/client-vpn-ca.key")
#   certificate_body = file("certs/client-vpn-ca.crt")
#   certificate_chain = file("certs/ca-chain.crt")

#   tags = local.global_tags
# }

# resource "aws_security_group" "vpn_access" {
#   vpc_id = aws_vpc.main.id
#   name = "vpn-example-sg"

#   ingress {
#     from_port = 443
#     protocol = "UDP"
#     to_port = 443
#     cidr_blocks = [
#       "0.0.0.0/0"]
#     description = "Incoming VPN connection"
#   }

#   egress {
#     from_port = 0
#     protocol = "-1"
#     to_port = 0
#     cidr_blocks = [
#       "0.0.0.0/0"]
#   }

#   tags = local.global_tags
# }

# resource "aws_ec2_client_vpn_endpoint" "vpn" {
#   description = "Client VPN example"
#   client_cidr_block = "10.20.0.0/22"
#   split_tunnel = true
#   server_certificate_arn = aws_acm_certificate_validation.vpn_server.certificate_arn

#   authentication_options {
#     type = "certificate-authentication"
#     root_certificate_chain_arn = aws_acm_certificate.vpn_client_root.arn
#   }

#   connection_log_options {
#     enabled = false
#   }

#   tags = local.global_tags
# }

# resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
#   count = length(aws_subnet.sn_az)

#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
#   subnet_id = aws_subnet.sn_az[count.index].id
#   security_groups = [aws_security_group.vpn_access.id]

#   lifecycle {
#     // The issue why we are ignoring changes is that on every change
#     // terraform screws up most of the vpn assosciations
#     // see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
#     ignore_changes = [subnet_id]
#   }
# }

# resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
#   target_network_cidr = aws_vpc.main.cidr_block
#   authorize_all_groups = true
# }
