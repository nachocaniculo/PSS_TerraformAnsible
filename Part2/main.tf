resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "static_website" {
  bucket = "nachocaniculo-final-practice-bucketv2"

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_website.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.static_website.bucket
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
}
