output "stack_name" {
  value = local.stack_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = var.aws_region
}

output "iam" {
  value     = module.iam
  sensitive = true
}

output "acm" {
  value = module.acm
}

# output "route53_hosted_zone_id" {
#   value = module.route53.hosted_zone_id
# }

# output "acm_certificate_arn" {
#   value = module.acm.certificate_arn
# }

output "ecs" {
  value = module.ecs
}

output "ecr" {
  value = module.ecr
}

output "s3" {
  value = module.s3
}

output "vpc" {
  value = module.vpc
}

output "aurora" {
  value     = module.aurora
  sensitive = true
}

output "elasticache" {
  value = module.elasticache
}

output "elasticsearch" {
  value = module.elasticsearch
}

output "sqs" {
  value = module.sqs
}

output "ssm" {
  value     = module.ssm
  sensitive = true
}
