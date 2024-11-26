variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "private_route_table_ids" {
  description = "The private route table ID"
  type        = list(string)
}
