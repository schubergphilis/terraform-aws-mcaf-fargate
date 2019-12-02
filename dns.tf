locals {
  application_fqdn = var.subdomain != null && local.load_balancer != null ? replace(
    "${var.subdomain.name}.${data.aws_route53_zone.current[0].name}", "/[.]$/", "",
  ) : null

  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.default.0.arn
  certificate_count = var.certificate_arn == null && var.subdomain != null ? local.load_balancer_count : 0
}

data "aws_route53_zone" "current" {
  count   = var.subdomain != null ? local.load_balancer_count : 0
  zone_id = var.subdomain.zone_id
}

resource "aws_route53_record" "default" {
  count   = var.subdomain != null ? local.load_balancer_count : 0
  zone_id = data.aws_route53_zone.current[0].zone_id
  name    = local.application_fqdn
  type    = "CNAME"
  ttl     = "5"
  records = [aws_alb.default[0].dns_name]
}

resource "aws_acm_certificate" "default" {
  count             = local.certificate_count
  domain_name       = local.application_fqdn
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count   = local.certificate_count
  zone_id = data.aws_route53_zone.current[0].zone_id
  name    = aws_acm_certificate.default[0].domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.default[0].domain_validation_options.0.resource_record_type
  ttl     = 60
  records = [aws_acm_certificate.default[0].domain_validation_options.0.resource_record_value]
}

resource "aws_acm_certificate_validation" "default" {
  count                   = var.certificate_arn == null ? local.load_balancer_count : 0
  certificate_arn         = local.certificate_arn
  validation_record_fqdns = [local.application_fqdn]
}
