variable "my_ip" {
  description = "Your public IP (check at https://nordvpn.com/fr/what-is-my-ip/)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = contains(["eu-west-3"], var.region)
    error_message = "Region should be: ..."
  }
}
