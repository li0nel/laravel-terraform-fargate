output "certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "certificate_validation_record_name" {
  value = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
}

output "certificate_validation_record_type" {
  value = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
}

output "certificate_validation_record_value" {
  value = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value
}
