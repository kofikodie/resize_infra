resource "aws_s3_bucket" "primary" {
  bucket = var.primary_name
}

resource "aws_s3_bucket_policy" "primary_policy" {
  bucket = aws_s3_bucket.primary.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ],
        Resource = [
          "${aws_s3_bucket.primary.arn}/*",
          "${aws_s3_bucket.primary.arn}"
        ],
      },
    ],
  })
}

resource "aws_s3_bucket" "tmp" {
  bucket = var.tmp_name
}

resource "aws_s3_bucket_policy" "tmp_policy" {
  bucket = aws_s3_bucket.tmp.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "*",
        Resource = [
          "${aws_s3_bucket.tmp.arn}/*",
          "${aws_s3_bucket.tmp.arn}"
        ],
      },
    ],
  })
}
