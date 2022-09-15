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

# Network

variable "vpc" {
  type = any
}

variable "public_subnet" {
  type = list(string)
}

variable "sg_rds_connect_id" {
  type = any
}

# database

variable "rds_endpoint" {
  type = string
}

variable "rds_port" {
  type = string
}

variable "region" {
  type = string
}

variable "rds_engine" {
  type = string
}
