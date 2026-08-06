output "app_url" {
  description = "Open this URL to access Superset"
  value       = module.alb.app_url
}

output "domain_name" {
  value = module.alb.domain_name
}

output "alb_dns_name" {
  description = "Cloudflare CNAME target for your domain"
  value       = module.alb.alb_dns_name
}

output "cloudflare_app_cname" {
  description = "App hostname CNAME to add in Cloudflare (DNS only / grey cloud)"
  value       = module.alb.cloudflare_app_cname
}

output "acm_validation_records" {
  description = "ACM validation CNAMEs to add in Cloudflare (DNS only / grey cloud)"
  value       = module.alb.acm_validation_records
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
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
  description = "Initial admin password (change after first login)"
  value       = random_password.admin.result
  sensitive   = true
}
