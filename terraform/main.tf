provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project = var.name
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

terraform {
  backend "s3" {
  }
}

data "aws_availability_zones" "available" {}

# custom KMS key used to manage encrypted resources
resource "aws_kms_key" "main" {
  description             = "Custom key used for AWS resources"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name}_kms"
  target_key_id = aws_kms_key.main.key_id
}

# s3 bucket to store remote state
resource "aws_s3_bucket" "remote-state" {
  bucket = "${var.name}-state.${data.aws_caller_identity.current.account_id}-${var.region}"
}

resource "aws_s3_bucket_acl" "remote-state" {
  bucket = aws_s3_bucket.remote-state.bucket
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "remote-state" {
  bucket = aws_s3_bucket.remote-state.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote-state" {
  bucket = aws_s3_bucket.remote-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.main.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "remote-state" {
  bucket = aws_s3_bucket.remote-state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# dynamodb table for locking the state file
resource "aws_dynamodb_table" "state-lock" {
  name           = "${var.name}-locks"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_caller_identity" "current" {}
