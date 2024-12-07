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

variable "namespace" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type    = string
  default = "resize-cluster"
}

variable "externalservices_prometheus_host" {
  type = string
}

variable "externalservices_prometheus_basicauth_username" {
  type    = number
  default = 1942040
}

variable "externalservices_prometheus_basicauth_password" {
  type = string
}

variable "externalservices_loki_host" {
  type = string
}

variable "externalservices_loki_basicauth_username" {
  type    = number
  default = 1070297
}

variable "externalservices_loki_basicauth_password" {
  type = string
}

variable "externalservices_tempo_host" {
  type = string
}

variable "externalservices_tempo_basicauth_username" {
  type    = number
  default = 1064612
}

variable "externalservices_tempo_basicauth_password" {
  type = string
}
