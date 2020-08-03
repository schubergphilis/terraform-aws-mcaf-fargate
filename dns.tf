locals {
  application_fqdn = var.subdomain != null && local.load_balancer != null ? replace(
    "${var.subdomain.name}.${data.aws_route53_zone.current[0].name}", "/[.]$/", "",
  ) : null

  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.default[0].arn
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
  records = [aws_lb.default[0].dns_name]
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
  for_each = {
    for dvo in aws_acm_certificate.default[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.current[0].zone_id
}

resource "aws_acm_certificate_validation" "default" {
  count                   = local.certificate_count
  certificate_arn         = local.certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
