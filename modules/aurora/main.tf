resource "random_password" "rds_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "final_snapshot_id" {
  length  = 12
  special = false
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora_db_subnet_group_${var.stack_name}"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "db_security_group" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  engine                       = "aurora-mysql"
  engine_version               = "5.7.mysql_aurora.2.07.2"
  database_name                = replace(var.stack_name, "/[^a-zA-Z0-9]+/", "")
  master_username              = "aurora"
  master_password              = random_password.rds_master_password.result
  backup_retention_period      = 35
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "wed:03:00-wed:04:00"
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.name
  final_snapshot_identifier    = join("-", [var.stack_name, random_string.final_snapshot_id.result, "0"])
  port                         = var.port

  vpc_security_group_ids = [
    aws_security_group.db_security_group.id,
  ]
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count                = 1
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.t2.small"
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  publicly_accessible  = false
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.07.2"
}

