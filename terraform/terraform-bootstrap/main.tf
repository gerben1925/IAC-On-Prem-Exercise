resource "aws_s3_bucket" "terraform_state" {
  bucket = var.rustfs_bucket
}