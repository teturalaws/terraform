output "s3_bucket_id" {
  value       = aws_s3_bucket.terrraform_state.id       
  sensitive   = false
  description = "The ID of the S3 bucket used for Terraform state"
  depends_on  = [aws_s3_bucket.terrraform_state]
}

output "dynamodb_table_id" {    
  value       = aws_dynamodb_table.terraform_locks.id       
  sensitive   = false
  description = "The ID of the DynamoDB table used for Terraform state locking"
  depends_on  = [aws_dynamodb_table.terraform_locks]
}