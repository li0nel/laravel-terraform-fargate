resource "aws_security_group" "es" {
  name   = "elasticsearch-${var.stack_name}"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.selected.cidr_block,
    ]
  }
}

# resource "aws_iam_service_linked_role" "es" {
#   aws_service_name = "es.amazonaws.com"
# }

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.stack_name
  elasticsearch_version = "7.10"

  vpc_options {
    subnet_ids = [
      var.subnet_ids[0]
    ]

    security_group_ids = [aws_security_group.es.id]
  }

  cluster_config {
    instance_type = "t3.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = "true"
    volume_type = "gp2"
    volume_size = "10"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
              "AWS": [
                  "${var.aws_iam_role.arn}"
              ]
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.stack_name}/*"
        }
    ]
}
CONFIG

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.log_group.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  # depends_on = [data.aws_iam_service_linked_role.es]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.stack_name}-elasticsearch"
}

resource "aws_cloudwatch_log_resource_policy" "policy" {
  policy_name = var.stack_name

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

