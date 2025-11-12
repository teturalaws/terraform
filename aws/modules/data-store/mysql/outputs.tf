output "address" {
  value       = aws_db_instance.mysql_instance.address
  sensitive   = false
  description = "The address of the MySQL database instance"    
}

output "port" {
  value       = aws_db_instance.mysql_instance.port
  description = "The port of the MySQL database instance"    
}

output "db_name" {
  value       = aws_db_instance.mysql_instance.db_name
  description = "The name of the MySQL database instance"    
}