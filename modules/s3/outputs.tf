output "bucket_name" { value = aws_s3_bucket.main.id }
output "bucket_arn"  { value = aws_s3_bucket.main.arn }
output "bucket_url"  { value = "s3://${aws_s3_bucket.main.id}" }
