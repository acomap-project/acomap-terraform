# create a API Gateway
resource "aws_api_gateway_rest_api" "acomap_project_api" {
  name        = "acomap-project-api"
  description = "API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Project = "acomap-project"
  }
}

output "acomap_project_api_id" {
  value = aws_api_gateway_rest_api.acomap_project_api.id
}

output "acomap_project_api_root_resource_id" {
  value = aws_api_gateway_rest_api.acomap_project_api.root_resource_id
}

output "acomap_project_api_execution_arn" {
  value = aws_api_gateway_rest_api.acomap_project_api.execution_arn
}