variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "database_url" {
  type      = string
  sensitive = true
}

variable "redis_url" {
  type = string
}

variable "superset_secret_key" {
  type      = string
  sensitive = true
}

variable "superset_admin_password" {
  type      = string
  sensitive = true
}
