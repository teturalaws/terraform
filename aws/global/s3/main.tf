provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terrraform_state" {
    bucket = "mytfstate-teturalaws" # Change to a unique bucket name
    lifecycle {
        prevent_destroy = true
    }
    tags = {
        Name        = "Terraform State Bucket"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
    bucket                  = aws_s3_bucket.terrraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.terrraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
    bucket = aws_s3_bucket.terrraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name         = "terraform-locks-teturalaws" # Change to a unique table name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Name        = "Terraform Locks Table"
        Environment = "Dev"
    }
}

terraform {
    backend "s3" {
        bucket         = "mytfstate-teturalaws" # Change to the same unique bucket name
        key            = "global/s3/terraform.tfstate"
        region         = "us-east-2"
        dynamodb_table = "terraform-locks-teturalaws" # Change to the same unique table name
        encrypt        = true
    }   
}