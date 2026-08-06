variable "project_name" { type = string }
variable "environment" { type = string }
variable "domain_name" { type = string }

variable "enable_https" {
  type    = bool
  default = false
}
