variable "aws_region" {
  type = string
}

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

variable "vpc" {
  type = any
}

variable "private_subnet_ids" {
  description = "List of already existing private subnets."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of already existing public subnets."
  type        = list(string)
}

variable "db_engine" {
  type = string
}

variable "db_port" {
  type = number
}

variable "secret_id" {
  default = ""
}