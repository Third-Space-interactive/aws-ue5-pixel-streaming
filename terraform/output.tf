output "frontend_url" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}
