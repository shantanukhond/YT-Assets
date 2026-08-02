output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "database_url" {
  value     = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive = true
}
