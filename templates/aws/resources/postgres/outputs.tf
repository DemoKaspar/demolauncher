# Standard outputs for postgres resource type
output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.postgres.username}:${aws_db_instance.postgres.password}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}

output "hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "database" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Database username"
  value       = aws_db_instance.postgres.username
}

output "password" {
  description = "Database password"
  value       = aws_db_instance.postgres.password
  sensitive   = true
}