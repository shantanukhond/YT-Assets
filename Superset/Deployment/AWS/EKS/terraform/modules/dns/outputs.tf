output "certificate_arn" {
  value = var.enable_https ? aws_acm_certificate_validation.main[0].certificate_arn : aws_acm_certificate.main.arn
}

output "domain_name" {
  value = var.domain_name
}

output "app_url" {
  value = "https://${var.domain_name}"
}

output "acm_validation_records" {
  description = "Cloudflare DNS records required to issue the ACM certificate"
  value = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}
