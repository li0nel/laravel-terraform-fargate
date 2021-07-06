// TODO any other subdomain should redirect to APEX
# module "route53" {
#   source       = "./modules/route53"
#   domain       = var.domain
#   hostname     = local.hostname
#   alb_hostname = module.ecs.ecs_alb_hostname
#   alb_zone_id  = module.ecs.ecs_alb_zone_id

#   providers = {
#     aws = "aws.us-east-1"
#   }
# }

# module "acm" {
#   source         = "./modules/acm"
#   hostname       = local.hostname
#   hosted_zone_id = module.route53.hosted_zone_id
# }

# module "cloudfront" {
#   source         = "./modules/cloudfront"
#   hostname       = local.hostname
# }

module "vpc" {
  source        = "./modules/vpc"
  stack_name    = local.stack_name
  b_nat_gateway = false
}

module "iam" {
  source     = "./modules/iam"
  stack_name = local.stack_name
}

module "aurora" {
  source     = "./modules/aurora"
  stack_name = local.stack_name
  subnet_ids = module.vpc.private_subnets.*.id
  vpc_id     = module.vpc.vpc.id
}

module "ecr" {
  source               = "./modules/ecr"
  stack_name           = replace(local.stack_name, "/[^a-zA-Z0-9]+/", "")
  ci_pipeline_user_arn = module.iam.ci_pipeline_arn
  ecs_role             = module.iam.ecs_role
}

module "s3" {
  source     = "./modules/s3"
  stack_name = local.stack_name
}

module "elasticache" {
  source     = "./modules/elasticache"
  stack_name = local.stack_name
  subnet_ids = module.vpc.private_subnets.*.id
  vpc_id     = module.vpc.vpc.id
}

module "elasticsearch" {
  source     = "./modules/elasticsearch"
  stack_name = local.stack_name
  vpc_id     = module.vpc.vpc.id
  subnet_ids = module.vpc.private_subnets.*.id
}

module "sqs" {
  source             = "./modules/sqs"
  stack_name         = local.stack_name
  vpc_id             = module.vpc.vpc.id
  private_subnet_ids = module.vpc.private_subnets.*.id
  security_group_ids = [module.ecs.aws_security_group.id]
}

module "ssm" {
  source     = "./modules/ssm"
  stack_name = local.stack_name
}

module "cloudwatch" {
  source     = "./modules/cloudwatch"
  stack_name = local.stack_name
}

module "ecs" {
  source             = "./modules/ecs"
  stack_name         = local.stack_name
  vpc_id             = module.vpc.vpc.id
  public_subnet_ids  = module.vpc.public_subnets.*.id
  private_subnet_ids = module.vpc.private_subnets.*.id
  role               = module.iam.ecs_role
  # certificate_arn            = module.acm.certificate_arn
  # hostname                   = local.hostname

  aws_rds_cluster = module.aurora.aws_rds_cluster
  aws_s3_bucket   = module.s3.aws_s3_bucket

  ecr_laravel_repository_uri = module.ecr.laravel_repository_uri
  ecr_nginx_repository_uri   = module.ecr.nginx_repository_uri

  aws_sqs_queue           = module.sqs.aws_sqs_queue
  aws_elasticache_cluster = module.elasticache.aws_elasticache_cluster

  aws_ssm_parameter = module.ssm.aws_ssm_parameter

  aws_elasticsearch_domain = module.elasticsearch.aws_elasticsearch_domain
}