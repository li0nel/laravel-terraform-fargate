data "aws_region" "current" {}

data "aws_ami" "awslinux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "vm" {
  ami                         = data.aws_ami.awslinux2.id
  instance_type               = "t2.nano"
  associate_public_ip_address = false
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  subnet_id                   = var.subnet_id
  iam_instance_profile        = aws_iam_instance_profile.vm_profile.name
}

resource "aws_security_group" "ec2_security_group" {
  name   = "${var.stack_name}-ec2"
  vpc_id = var.vpc_id

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "vm_profile" {
  name = "vm_profile_${var.stack_name}"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name               = "ec2_role_${var.stack_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "s3:GetEncryptionConfiguration"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ssm:UpdateInstanceInformation"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

# allow task execution role to be assumed by ecs
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  public_key_filename  = "./key-${terraform.workspace}.pub"
  private_key_filename = "./key-${terraform.workspace}"
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  depends_on = [tls_private_key.default]
  key_name   = "key-${var.stack_name}"
  public_key = tls_private_key.default.public_key_openssh
}

resource "local_file" "public_key_openssh" {
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default.public_key_openssh
  filename   = local.public_key_filename
}

resource "local_file" "private_key_pem" {
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default.private_key_pem
  filename   = local.private_key_filename
}

resource "null_resource" "chmod" {
  depends_on = [local_file.private_key_pem]

  provisioner "local-exec" {
    command = "chmod 400 ${local.private_key_filename}"
  }
}

# data "aws_vpc" "selected" {
#   id    = var.vpc_id
# }

# # Create VPC Endpoints For Session Manager
# resource "aws_security_group" "ssm_sg" {
#   name        = "ssm-sg-${stack_name}"
#   description = "Allow TLS inbound To AWS Systems Manager Session Manager"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "HTTPS from VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
#   }

#   egress {
#     description = "Allow All Egress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id            = var.vpc_id
#   subnet_ids        = [var.subnet_id]
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.ssm_sg.id
#   ]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id            = var.vpc_id
#   subnet_ids        = [var.subnet_id]
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.ssm_sg.id
#   ]

#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id            = var.vpc_id
#   subnet_ids        = [var.subnet_id]
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.ssm_sg.id
#   ]

#   private_dns_enabled = true
# }
