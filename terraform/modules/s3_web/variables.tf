variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versionned" {
  description = "If True, enable S3 versionning."
  type        = bool
  default     = false
}

variable "cloudfront_config" {
  description = "Configuration for Cloudfront Distribution"
  type = object({
    description     = string
    origin_id       = string
    allowed_methods = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods  = optional(list(string), ["GET", "HEAD"])
  })
}
