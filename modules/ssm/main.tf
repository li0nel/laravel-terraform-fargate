resource "aws_ssm_parameter" "secret" {
  name  = "${var.stack_name}-example-secret"
  type  = "SecureString"
  value = "dummy"
}
