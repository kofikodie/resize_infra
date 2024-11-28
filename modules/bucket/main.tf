resource "aws_s3_bucket" "primary" {
  bucket = var.primary_name
}

resource "aws_s3_bucket" "tmp" {
  bucket = var.tmp_name
}
