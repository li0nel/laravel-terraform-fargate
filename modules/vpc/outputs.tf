# module.vpc.aws_vpc.vpc
output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "public_rt_associations" {
  value = aws_route_table_association.public_rt_associations
}

output "private_rt_associations" {
  value = aws_route_table_association.private_rt_associations
}

output "public_routetable" {
  value = aws_route_table.public_routetable
}

output "private_routetable" {
  value = aws_route_table.private_routetable
}

output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway
}
