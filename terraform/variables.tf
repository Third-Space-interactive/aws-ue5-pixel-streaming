variable "instance_os" {
  description = "OS for the Pixel Streaming instance (either 'windows' or 'linux')"
  type        = string

  validation {
    condition     = var.instance_os == "windows" || var.instance_os == "linux"
    error_message = "Value should be either 'windows' or 'linux'"
  }
}

variable "my_ip" {
  description = "Your public IP (check at https://nordvpn.com/fr/what-is-my-ip/)"
  type        = string
}
