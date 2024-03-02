terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "ap-southeast-1"
}

module "accom" {
  source = "./modules/accommodation-service"
}

module "acomap-client-web-app" {
  source = "./modules/acomap-client-web-app"
}