# Depend on the secret *version* so ECS does not start before AWSCURRENT exists.
# Referencing only the secret ARN lets Terraform create services against an empty shell.
output "secret_arn" {
  value      = aws_secretsmanager_secret.superset.arn
  depends_on = [aws_secretsmanager_secret_version.superset]
}
