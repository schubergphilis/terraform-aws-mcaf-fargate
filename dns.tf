locals {
    application_fqdn = replace("${var.subdomain}.${data.aws_route53_zone.current.name}", "/[.]$/", "")
}

data "aws_route53_zone" "current" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "fargate" {
  zone_id = data.aws_route53_zone.current.zone_id
  name    = local.application_fqdn
  type    = "CNAME"
  ttl     = "5"
  records = [aws_alb.default.dns_name]
}

resource "aws_acm_certificate" "fargate" {
  domain_name       = aws_route53_record.fargate.fqdn
  validation_method = "DNS"
  tags              = var.tags
}

resource "aws_route53_record" "fargate_cert_validation" {
  zone_id = data.aws_route53_zone.current.zone_id
  name    = aws_acm_certificate.fargate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.fargate.domain_validation_options.0.resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.fargate.domain_validation_options.0.resource_record_value]
}

resource "aws_acm_certificate_validation" "fargate" {
  certificate_arn         = aws_acm_certificate.fargate.arn
  validation_record_fqdns = [aws_route53_record.fargate_cert_validation.fqdn]
}
