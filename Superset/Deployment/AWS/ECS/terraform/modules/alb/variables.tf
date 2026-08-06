variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "Custom domain for Superset, e.g. app.superset.atwish.org"
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Set true after adding ACM validation CNAMEs in Cloudflare"
}
