output "frontend_url" {
  value = "https://${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}api/create-instance"
}