output "alb_dns_name" {
  value = aws_lb.main.dns_name
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
  value = "https://${var.domain_name}"
}

output "certificate_arn" {
  value = aws_acm_certificate.main.arn
}
