output "certificate_arn" {
  value = aws_acm_certificate_validation.main.certificate_arn
}

output "domain_name" {
  value = var.domain_name
}

output "zone_id" {
  value = data.aws_route53_zone.main.zone_id
}

output "app_url" {
  value = "https://${var.domain_name}"
}
