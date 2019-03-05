resource "aws_s3_bucket" "ci" {
  bucket        = "ct-backup-pipeline"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
