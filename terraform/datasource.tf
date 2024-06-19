locals {
  availabilty_zones = data.aws_availability_zones.az.names
}

data "aws_availability_zones" "az" {}
