terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_password" "db" {
  length  = 24
  special = false
}

resource "random_password" "superset_secret_key" {
  length  = 42
  special = false
}

resource "random_password" "admin" {
  length  = 16
  special = false
}

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_name           = var.cluster_name
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  rds_security_group_id   = module.vpc.rds_security_group_id
  db_username             = var.db_username
  db_password             = random_password.db.result
}

module "redis" {
  source = "./modules/redis"

  project_name            = var.project_name
  environment             = var.environment
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  redis_security_group_id = module.vpc.redis_security_group_id
}

module "secrets" {
  source = "./modules/secrets"

  project_name            = var.project_name
  environment             = var.environment
  database_url            = module.rds.database_url
  redis_url               = module.redis.redis_url
  superset_secret_key     = random_password.superset_secret_key.result
  superset_admin_password = random_password.admin.result
}

module "dns" {
  source = "./modules/dns"

  project_name      = var.project_name
  environment       = var.environment
  domain_name       = var.domain_name
  route53_zone_name = var.route53_zone_name
}
