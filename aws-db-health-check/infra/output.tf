output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "The name of the DB instance."
}

output "db_id" {
  value       = aws_db_instance.main.identifier
  description = "The id of the DB instance."
}

output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "The public DNS name of the DB instance."
}

output "db_user" {
  value       = aws_db_instance.main.username
  description = "The master username for the DB instance."
}

output "db_password" {
  value       = aws_db_instance.main.password
  description = "The master password for the DB instance."
  sensitive   = true
}
