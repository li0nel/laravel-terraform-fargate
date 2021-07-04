# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = "${data.aws_s3_bucket.b.website_endpoint}"
#     origin_id   = "s3_origin"

#     custom_origin_config {
#       origin_protocol_policy = "http-only"
#       http_port              = 80
#       https_port             = 443
#       origin_ssl_protocols   = ["TLSv1", "SSLv3"]
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   logging_config {
#     include_cookies = true
#     bucket          = "${aws_s3_bucket.logs_bucket.bucket_domain_name}"
#     prefix          = "cloudfront_logs"
#   }

#   aliases = ["${var.stack_name}.cdn.${var.domain_name}"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "s3_origin"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     lambda_function_association {
#       event_type = "origin-request"
#       lambda_arn = "${aws_lambda_function.lambda_at_edge.arn}:${aws_lambda_function.lambda_at_edge.version}"
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 900
#     max_ttl                = 86400
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn = "${data.aws_acm_certificate.certificate.arn}"
#     ssl_support_method  = "sni-only"
#   }
# }