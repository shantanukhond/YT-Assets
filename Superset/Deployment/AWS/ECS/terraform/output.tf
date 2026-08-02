output "alb_url" {
  description = "Open this URL to access Superset"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
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
