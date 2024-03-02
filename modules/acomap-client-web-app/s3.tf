# create an s3 bucket with name 'acomap-web-app' and allow static hosting
resource "aws_s3_bucket" "acomap-client-web-app" {
  bucket = "acomap-client-web-app"
}

resource "aws_s3_bucket_public_access_block" "acomap-client-web-app-public-access-block" {
  bucket = aws_s3_bucket.acomap-client-web-app.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_website_configuration" "acomap-client-web-app" {
  bucket = aws_s3_bucket.acomap-client-web-app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "acomap-client-web-app" {
  bucket = aws_s3_bucket.acomap-client-web-app.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

# create a bucket policy that allows public read access to the bucket
resource "aws_s3_bucket_policy" "acomap-client-web-app" {
  bucket = aws_s3_bucket.acomap-client-web-app.id
  depends_on = [ aws_s3_bucket.acomap-client-web-app, aws_s3_bucket_public_access_block.acomap-client-web-app-public-access-block ]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.acomap-client-web-app.arn}/*",
      },
    ],
  })
}
