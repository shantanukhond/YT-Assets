locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_secretsmanager_secret" "superset" {
  name = "${local.name}/superset"

  tags = {
    Name = "${local.name}-superset-secrets"
  }
}

resource "aws_secretsmanager_secret_version" "superset" {
  secret_id = aws_secretsmanager_secret.superset.id

  secret_string = jsonencode({
    SUPERSET_SECRET_KEY     = var.superset_secret_key
    DATABASE_URL            = var.database_url
    REDIS_URL               = var.redis_url
    SUPERSET_ADMIN_PASSWORD = var.superset_admin_password
  })
}
