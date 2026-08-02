variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
