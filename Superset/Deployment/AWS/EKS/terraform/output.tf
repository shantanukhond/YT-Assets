output "app_url" {
  value = module.dns.app_url
}

output "domain_name" {
  value = module.dns.domain_name
}

output "certificate_arn" {
  value = module.dns.certificate_arn
}

output "acm_validation_records" {
  description = "ACM validation CNAMEs to add in Cloudflare (DNS only / grey cloud)"
  value       = module.dns.acm_validation_records
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "alb_controller_role_arn" {
  value = module.eks.alb_controller_role_arn
}

output "secret_arn" {
  value = module.secrets.secret_arn
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "redis_endpoint" {
  value = module.redis.redis_endpoint
}

output "superset_admin_username" {
  value = var.superset_admin_username
}

output "superset_admin_password" {
  value     = random_password.admin.result
  sensitive = true
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
