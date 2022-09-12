provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1"
    }
  }
}
