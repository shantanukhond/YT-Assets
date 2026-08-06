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
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate passwords/keys — no need to hardcode secrets
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
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
  domain_name           = var.domain_name
  enable_https          = var.enable_https
}

module "rds" {
  source = "./modules/rds"

  project_name              = var.project_name
  environment               = var.environment
  private_data_subnet_ids   = module.vpc.private_data_subnet_ids
  rds_security_group_id     = module.vpc.rds_security_group_id
  db_username               = var.db_username
  db_password               = random_password.db.result
}

module "redis" {
  source = "./modules/redis"

  project_name              = var.project_name
  environment               = var.environment
  private_data_subnet_ids   = module.vpc.private_data_subnet_ids
  redis_security_group_id   = module.vpc.redis_security_group_id
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

module "ecs" {
  source = "./modules/ecs"

  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  superset_image           = var.superset_image
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  ecs_security_group_id    = module.vpc.ecs_security_group_id
  target_group_arn         = module.alb.target_group_arn
  secret_arn               = module.secrets.secret_arn
  web_desired_count        = var.web_desired_count
  worker_desired_count     = var.worker_desired_count
  beat_desired_count       = var.beat_desired_count
  superset_admin_username  = var.superset_admin_username
  superset_admin_email     = var.superset_admin_email
}
