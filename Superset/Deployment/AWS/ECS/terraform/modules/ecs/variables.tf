variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "superset_image" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "secret_arn" {
  type = string
}

variable "web_desired_count" {
  type = number
}

variable "worker_desired_count" {
  type = number
}

variable "beat_desired_count" {
  type = number
}

variable "superset_admin_username" {
  type = string
}

variable "superset_admin_email" {
  type = string
}
