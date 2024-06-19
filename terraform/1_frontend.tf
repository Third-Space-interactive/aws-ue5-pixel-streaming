locals {
  bucket_name   = "aws-ue5-pixel-streaming-frontend"
  frontend_path = "${abspath(path.cwd)}/../frontend"

  cloudfront_config = {
    origin_id       = "frontend"
    description     = "Frontend Distribution"
    cached_methods  = ["GET", "HEAD"]
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
  }

  mime_types = {
    ".html" = "text/html"
    ".json" = "application/json"
    ".js"   = "application/javascript"
    ".ico"  = "image.vnd.microsoft.icon"
    ".png"  = "image.png"
    ".svg"  = "image/svg+xml"
    ".css"  = "text/css"
    ".txt"  = "text/plain"
  }
}

###############
# S3 Bucket & S3 Configuration
###############
resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]
}

###############
# Cloudfront OAI
###############
resource "aws_cloudfront_origin_access_identity" "oai" {}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_access.json
}

###############
# Cloudfront Distribution
###############
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled             = true
  wait_for_deployment = false
  comment             = local.cloudfront_config.description
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.cloudfront_config.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = local.cloudfront_config.origin_id
    allowed_methods        = local.cloudfront_config.allowed_methods
    cached_methods         = local.cloudfront_config.cached_methods
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
}

###############
# Upload Frontend 
###############
resource "aws_s3_object" "frontend" {
  for_each = fileset(local.frontend_path, "**")

  bucket       = aws_s3_bucket.bucket.bucket
  key          = each.value
  source       = "${local.frontend_path}/${each.value}"
  source_hash  = filemd5("${local.frontend_path}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}
