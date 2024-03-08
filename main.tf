variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "ap-southeast-1"
}

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
  region = var.aws_region
}

module "common" {
  source = "./modules/_common"
}

module "accom" {
  source = "./modules/accommodation-service"
  api_gateway_id = module.common.acomap_project_api_id
  api_gateway_root_resource_id = module.common.acomap_project_api_root_resource_id
  api_gateway_execution_arn = module.common.acomap_project_api_execution_arn
}

module "crawl-service" {
  source = "./modules/crawl-service"
  accom_service_sqs_url = module.accom.accommodation_queue_url
}

module "acomap-client-web-app" {
  source = "./modules/acomap-client-web-app"
}