resource "aws_acm_certificate" "certificate" {
  domain_name       = length(var.subdomain) == 0 ? var.domain : join(".", [var.subdomain, var.domain])
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  count   = var.hosted_zone_id == null ? 0 : 1
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id = var.hosted_zone_id
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 5
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  count                   = var.hosted_zone_id == null ? 0 : 1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation[0].fqdn]
}
