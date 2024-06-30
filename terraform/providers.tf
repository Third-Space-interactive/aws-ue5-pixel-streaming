terraform {
  required_version = "1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.3.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = "<YOUR_AWS_ACCESS_KEY>"
  secret_key = "<YOUR_AWS_SECRET_KEY>"
}
