data "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "alias" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = length(var.subdomain) == 0 ? var.domain : join(".", [var.subdomain, var.domain])
  type    = "A"

  alias {
    name                   = var.alb_hostname
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
