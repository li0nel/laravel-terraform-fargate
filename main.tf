// TODO any other subdomain should redirect to APEX
module "route53" {
  count        = var.b_route53_zone ? 1 : 0
  source       = "./modules/route53"
  domain       = var.domain
  subdomain    = var.subdomain
  alb_hostname = module.ecs.ecs_alb_hostname
  alb_zone_id  = module.ecs.ecs_alb_zone_id

  providers = {
    aws.useast1 = aws.useast1
  }
}

module "acm" {
  source         = "./modules/acm"
  domain         = var.domain
  subdomain      = var.subdomain
  hosted_zone_id = var.b_route53_zone ? module.route53[0].hosted_zone_id : null
}

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
  # aws_iam_role = module.ecs.aws_iam_role
}

module "sqs" {
  source             = "./modules/sqs"
  stack_name         = local.stack_name
  vpc_id             = module.vpc.vpc.id
  subnet_ids         = module.vpc.public_subnets.*.id
  security_group_ids = [module.ecs.aws_security_group.id]
  aws_iam_role       = module.ecs.aws_iam_role
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
  certificate_arn    = module.acm.certificate_arn

  aws_rds_cluster = module.aurora.aws_rds_cluster
  aws_s3_bucket   = module.s3.aws_s3_bucket

  ecr_laravel_repository_uri = module.ecr.laravel_repository_uri
  ecr_nginx_repository_uri   = module.ecr.nginx_repository_uri

  aws_sqs_queue           = module.sqs.aws_sqs_queue
  aws_elasticache_cluster = module.elasticache.aws_elasticache_cluster

  aws_ssm_parameter = module.ssm.aws_ssm_parameter

  aws_elasticsearch_domain = module.elasticsearch.aws_elasticsearch_domain
}

module "ec2" {
  source = "./modules/ec2"

  stack_name = local.stack_name
  vpc_id     = module.vpc.vpc.id
  subnet_id  = module.vpc.private_subnets[0].id
}