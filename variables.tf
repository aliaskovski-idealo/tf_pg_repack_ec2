variable "namespace" {
  description = "Namespace or Project name of the environment"
  type        = string
}

variable "stage" {
  description = "Stage of the environment."
  type        = string
}

variable "name" {
  description = "Name of the environment."
  type        = string
}

#variable "enabled" {
#  type    = bool
#  default = true
#}
variable "region" {
  type    = string
  default = "eu-central-1"
}

# Network

variable "vpc_id" {
  type = any
}

variable "public_subnet_ids" {
  type = list(string)
}


variable "private_subnet_ids" {
  type = list(string)
}

#variable "sg_rds_connect_id" {
#  type = any
#}

variable "rds_endpoint" {
  type = string
}

variable "rds_port" {
  type = string
}