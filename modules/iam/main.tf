# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_user" "ci_pipeline" {
  name = terraform.workspace == "default" ? "ci_pipeline" : join("-", ["ci_pipeline", terraform.workspace])
  path = "/"
}

resource "aws_iam_access_key" "ci_pipeline" {
  user = aws_iam_user.ci_pipeline.name
}

resource "aws_iam_policy" "ci_pipeline" {
  path   = "/"
  policy = data.aws_iam_policy_document.ci_pipeline.json
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.ci_pipeline.name
  policy_arn = aws_iam_policy.ci_pipeline.arn
}
