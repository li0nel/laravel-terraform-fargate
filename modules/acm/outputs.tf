output "certificate_arn" {
  depends_on = [aws_acm_certificate_validation.certificate_validation]
  value      = aws_acm_certificate.certificate.arn
}