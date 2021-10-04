# don't use terraform-aws-modules/s3-bucket/aws because 
# can't set lifecycle attribute
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.terraform_bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_bucket_public_access" {
  bucket                  = aws_s3_bucket.tfstate_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  count          = var.terraform_state_lock_table_name == null ? 0 : 1
  name           = var.terraform_state_lock_table_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}