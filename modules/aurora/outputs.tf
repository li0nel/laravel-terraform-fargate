output "aurora_subnet_group" {
  value = aws_db_subnet_group.aurora_subnet_group
}

output "aws_rds_cluster" {
  value = aws_rds_cluster.aurora_cluster
}

output "aurora_cluster_instances" {
  value = aws_rds_cluster_instance.aurora_cluster_instance
}

output "db_security_group" {
  value = aws_security_group.db_security_group
}

output "final_snapshot_id" {
  value = random_string.final_snapshot_id
}

# output "rds_master_password" {
#   value     = random_password.rds_master_password
#   sensitive = true
# }
