# ---------------------------------------------
# S3バケットの作成
# --------------------------------------------- 
resource "aws_s3_bucket" "portal_bucket" {
  bucket = "${var.project}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project}-${var.environment}-bucket"
    Environment = var.environment
    Project     = var.project
  }
}

# ---------------------------------------------
# バケットのアクセス許可設定
# ---------------------------------------------
resource "aws_s3_bucket_acl" "portal_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.portal_bucket_ownership]
  bucket     = aws_s3_bucket.portal_bucket.id
  acl        = "private"
}

# ---------------------------------------------
# バージョニング設定
# ---------------------------------------------
resource "aws_s3_bucket_versioning" "portal_bucket_versioning" {
  bucket = aws_s3_bucket.portal_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------
# 暗号化設定
# ---------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "portal_bucket_encryption" {
  bucket = aws_s3_bucket.portal_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------
# バケットポリシーの設定
# ---------------------------------------------
resource "aws_s3_bucket_policy" "portal_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.portal_bucket_public_access_block]
  bucket     = aws_s3_bucket.portal_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/${var.project}-${var.environment}-bk-access-role"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.project}-${var.environment}-bucket/*",
          "arn:aws:s3:::${var.project}-${var.environment}-bucket"
        ]
      }
    ]
  })
}

# ---------------------------------------------
# オブジェクト所有権の設定
# ---------------------------------------------
resource "aws_s3_bucket_ownership_controls" "portal_bucket_ownership" {
  bucket = aws_s3_bucket.portal_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# ---------------------------------------------
# パブリックアクセスブロックの設定
# ---------------------------------------------
resource "aws_s3_bucket_public_access_block" "portal_bucket_public_access_block" {
  bucket = aws_s3_bucket.portal_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------
# CORS設定の追加
# ---------------------------------------------
resource "aws_s3_bucket_cors_configuration" "portal_bucket_cors" {
  bucket = aws_s3_bucket.portal_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["https://*.netlify.app"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}
