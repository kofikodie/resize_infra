variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_secondary_region" {
  default = "eu-central-1"
}

data "aws_availability_zones" "available" {}
