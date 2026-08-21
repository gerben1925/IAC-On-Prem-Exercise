output "terraform_state_bucket" {
  description = "Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

