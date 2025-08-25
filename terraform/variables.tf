variable "my_ip" {
  description = "Your IP (check at https://nordvpn.com/fr/what-is-my-ip/)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}
