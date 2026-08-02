output "secret_arn" {
  value = aws_secretsmanager_secret.superset.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.superset.name
}
