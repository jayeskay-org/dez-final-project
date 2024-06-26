terraform {
    required_version = ">= 1.0"
    backend "local" {}
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

# Configure AWS provider
provider "aws" {
    region  = var.region
    profile = var.profile
}
