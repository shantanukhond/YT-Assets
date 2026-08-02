variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "redis_security_group_id" {
  type = string
}
