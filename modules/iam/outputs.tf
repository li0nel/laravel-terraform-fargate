output "ci_pipeline_access_key_id" {
  value = aws_iam_access_key.ci_pipeline.id
}

output "ci_pipeline_access_key_secret" {
  value = aws_iam_access_key.ci_pipeline.secret
}

output "ci_pipeline_arn" {
  value = aws_iam_user.ci_pipeline.arn
}

output "ecs_role" {
  value = aws_iam_role.role.arn
}