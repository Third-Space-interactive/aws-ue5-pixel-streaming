variable "name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda" {
  description = "The configuration for the Lambda function"
  type = object({
    path        = string
    handler     = string
    runtime     = optional(string, "python3.11")
    timeout     = optional(number, 500)
    policies    = optional(list(string), [])
    environment = optional(map(string), {})
  })
}
