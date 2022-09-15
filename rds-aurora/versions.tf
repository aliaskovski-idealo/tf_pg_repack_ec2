terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}
