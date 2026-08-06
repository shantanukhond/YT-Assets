variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "superset-ecs"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "superset_image" {
  type    = string
  default = "apache/superset:4.1.1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "db_username" {
  type    = string
  default = "superset"
}

variable "web_desired_count" {
  type    = number
  default = 1
}

variable "worker_desired_count" {
  type    = number
  default = 1
}

# Beat must always be 1 — never scale this
variable "beat_desired_count" {
  type    = number
  default = 1
}

variable "superset_admin_username" {
  type    = string
  default = "admin"
}

variable "superset_admin_email" {
  type    = string
  default = "admin@example.com"
}

variable "domain_name" {
  type        = string
  default     = "app.superset.atwish.org"
  description = "Custom domain for Superset (DNS managed in Cloudflare)"
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Set true after adding ACM validation CNAMEs in Cloudflare, then re-apply"
}
