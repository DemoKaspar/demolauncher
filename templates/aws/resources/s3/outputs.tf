# Standard outputs for s3 resource type
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_storage.bucket
}

output "bucket_url" {
  description = "URL of the S3 bucket"
  value       = "https://${aws_s3_bucket.app_storage.bucket}.s3.amazonaws.com"
}

output "access_key_id" {
  description = "AWS access key ID for S3 access"
  value       = aws_iam_access_key.s3_user.id
}

output "secret_access_key" {
  description = "AWS secret access key for S3 access"
  value       = aws_iam_access_key.s3_user.secret
  sensitive   = true
}

output "region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.app_storage.region
}