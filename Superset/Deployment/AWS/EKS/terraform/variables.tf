variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "superset-eks"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  type    = string
  default = "superset-eks-dev"
}

variable "superset_image" {
  type    = string
  default = "apache/superset:4.1.1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "db_username" {
  type    = string
  default = "superset"
}

variable "web_replicas" {
  type    = number
  default = 1
}

variable "worker_replicas" {
  type    = number
  default = 1
}

# Beat must always be 1
variable "beat_replicas" {
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
  type    = string
  default = "app.superset.atwish.org"
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Set true after adding ACM validation CNAMEs in Cloudflare"
}
