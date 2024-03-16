resource "aws_api_gateway_resource" "raw-accoms" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "raw-accoms"
}

resource "aws_api_gateway_resource" "raw-accom-id" {
  rest_api_id = var.api_gateway_id
  parent_id   = aws_api_gateway_resource.raw-accoms.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "resolve_raw_accom" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = "PATCH"
  authorization = "NONE"
}

// add request mapping template for integration to map all query parameters to event of lambda
resource "aws_api_gateway_integration" "resolve_raw_accom_integration" {
  depends_on   = [aws_api_gateway_method.resolve_raw_accom]
  rest_api_id  = var.api_gateway_id
  resource_id  = aws_api_gateway_resource.raw-accom-id.id
  http_method  = aws_api_gateway_method.resolve_raw_accom.http_method
  integration_http_method = "POST"
  type         = "AWS" # Updated integration type to AWS_PROXY
  uri          = aws_lambda_function.raw-accom-function.invoke_arn

  request_templates = {
    "application/json" = <<EOF
    {
      "type": "api-gateway",
      "method": "resolve-accom",
      "body": {
        "_id": "$input.params('id')",
        "location": $input.json('location')
      } 
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "resolve_raw_accom_response" {
  depends_on    = [aws_api_gateway_integration.resolve_raw_accom_integration]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = aws_api_gateway_method.resolve_raw_accom.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "resolve_raw_accom_integration_response" {
  depends_on    = [aws_api_gateway_integration.resolve_raw_accom_integration]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = aws_api_gateway_method.resolve_raw_accom.http_method
  status_code   = "200"
  response_templates      = {
    "application/json" = "$input.json('$')"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# ENABLE CORS FOR /raw-accoms/{id} RESOURCE
resource "aws_api_gateway_method" "raw_accoms_option_method" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "raw_accoms_option_integration" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = aws_api_gateway_method.raw_accoms_option_method.http_method
  type          = "MOCK"
  request_templates = {
    "application/json" = <<EOF
    {
      "statusCode": 200,
      "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "PATCH, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,Authorization"
      }
    }
    EOF
  }
}



resource "aws_api_gateway_method_response" "accommodations_options_response" {
  depends_on = [ aws_api_gateway_integration.raw_accoms_option_integration ]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = "OPTIONS"
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "accommodations_options_integration_response" {
  depends_on = [ aws_api_gateway_integration.raw_accoms_option_integration ]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.raw-accom-id.id
  http_method   = "OPTIONS"
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'PATCH, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_deployment" "raw_accoms_deployment" {
  depends_on  = [
    aws_api_gateway_integration.resolve_raw_accom_integration,
    aws_api_gateway_integration.raw_accoms_option_integration
  ]
  rest_api_id = var.api_gateway_id
  stage_name  = "dev"
  triggers = {
    redeployment = sha1(
      jsonencode(
        merge(
          aws_api_gateway_integration.resolve_raw_accom_integration,
          aws_api_gateway_integration.raw_accoms_option_integration
        )
      )
    )
  }
  lifecycle {
    create_before_destroy = true
  }
}
