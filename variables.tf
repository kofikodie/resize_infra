variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_secondary_region" {
  default = "eu-central-1"
}

data "aws_availability_zones" "available" {}
