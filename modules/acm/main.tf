resource "aws_acm_certificate" "certificate" {
  domain_name       = var.hostname
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_type
  zone_id = var.hosted_zone_id
  records = [aws_acm_certificate.certificate.domain_validation_options[0].resource_record_value]
  ttl     = 5
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}