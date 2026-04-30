moved {
  from = aws_route53_record.validation["create"]
  to   = aws_route53_record.validation[0]
}
