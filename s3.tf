/*
Deploying s3 buckets everywhere
*/

resource "aws_s3_bucket" "rootwest" {
  bucket = "pub-${var.prefix}rootwest"
}

resource "aws_s3_bucket" "acct1west2" {
  bucket = "pub-${var.prefix}acct1west2"
  provider = aws.acct1west2
}

resource "aws_s3_bucket" "acct2west2" {
  bucket = "pub-${var.prefix}acct2west2"
  provider = aws.acct2west2
}