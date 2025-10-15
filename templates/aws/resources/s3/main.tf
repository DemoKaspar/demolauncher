terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Generate random ID for unique naming
resource "random_id" "s3" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "app_storage" {
  bucket = "app-storage-${random_id.s3.hex}"

  tags = {
    Name = "app-storage-${random_id.s3.hex}"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM User for S3 Access
resource "aws_iam_user" "s3_user" {
  name = "s3-user-${random_id.s3.hex}"

  tags = {
    Name = "s3-user-${random_id.s3.hex}"
  }
}

# IAM Access Key
resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy-${random_id.s3.hex}"
  description = "Policy for S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_storage.arn,
          "${aws_s3_bucket.app_storage.arn}/*"
        ]
      }
    ]
  })
}

# Attach Policy to User
resource "aws_iam_user_policy_attachment" "s3_user_policy" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}