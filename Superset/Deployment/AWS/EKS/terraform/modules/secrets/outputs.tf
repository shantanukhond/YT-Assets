# Depend on the secret *version* so callers (create-k8s-secret.sh) don't read
# the secret before AWSCURRENT exists.
output "secret_arn" {
  value      = aws_secretsmanager_secret.superset.arn
  depends_on = [aws_secretsmanager_secret_version.superset]
}

output "secret_name" {
  value = aws_secretsmanager_secret.superset.name
}
