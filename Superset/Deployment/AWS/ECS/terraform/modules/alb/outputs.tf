output "alb_dns_name" {
  description = "Add this as a Cloudflare CNAME target for your domain"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}

output "domain_name" {
  value = var.domain_name
}

output "app_url" {
  value = var.enable_https ? "https://${var.domain_name}" : "http://${aws_lb.main.dns_name}"
}

output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}

# Add these CNAMEs in Cloudflare (DNS only / grey cloud) to validate the ACM cert
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

output "cloudflare_app_cname" {
  description = "Cloudflare CNAME for the app hostname"
  value = {
    type    = "CNAME"
    name    = var.domain_name
    target  = aws_lb.main.dns_name
    proxied = false
  }
}
