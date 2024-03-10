variable "api_gateway_id" {
  description = "The ID of the API Gateway"
}

variable "api_gateway_execution_arn" {
  description = "The ARN of the API Gateway execution"
}

variable "api_gateway_root_resource_id" {
  description = "The ID of the root resource of the API Gateway"
}


resource "aws_api_gateway_resource" "accommodations" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "accommodations"
}

resource "aws_api_gateway_method" "accommodations_get" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.accommodations.id
  http_method   = "GET"
  authorization = "NONE"
  # define lambda integration for the GET method
}

// add request mapping template for integration to map all query parameters to event of lambda
resource "aws_api_gateway_integration" "accommodations_get_lambda" {
  depends_on   = [aws_api_gateway_method.accommodations_get]
  rest_api_id  = var.api_gateway_id
  resource_id  = aws_api_gateway_resource.accommodations.id
  http_method  = aws_api_gateway_method.accommodations_get.http_method
  integration_http_method = "POST"
  type         = "AWS" # Updated integration type to AWS_PROXY
  uri          = aws_lambda_function.accom-listing-function.invoke_arn

  request_templates = {
    "application/json" = <<EOF
    #set($allParams = $input.params().querystring)
    {
      #foreach($paramName in $allParams.keySet())
        "$paramName": "$util.escapeJavaScript($allParams.get($paramName))"
        #if($foreach.hasNext),#end
      #end
    }
    EOF
  }
}

resource "aws_lambda_permission" "api_gateway_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.accom-listing-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*"
}

resource "aws_api_gateway_method_response" "accommodations_get_response" {
  depends_on    = [aws_api_gateway_integration.accommodations_get_lambda]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.accommodations.id
  http_method   = aws_api_gateway_method.accommodations_get.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "accommodations_get_lambda_response" {
  depends_on              = [aws_api_gateway_integration.accommodations_get_lambda]
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_resource.accommodations.id
  http_method             = aws_api_gateway_method.accommodations_get.http_method
  status_code             = "200"
  response_templates      = {
    "application/json" = "$input.json('$')"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_method" "accommodations_options" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.accommodations.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "accommodations_options" {
  depends_on   = [aws_api_gateway_method.accommodations_options]
  rest_api_id  = var.api_gateway_id
  resource_id  = aws_api_gateway_resource.accommodations.id
  http_method  = aws_api_gateway_method.accommodations_options.http_method
  type         = "MOCK"
  request_templates = {
    "application/json" = <<EOF
    {
      "statusCode": 200,
      "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS, GET",
        "Access-Control-Allow-Headers": "Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token, X-Amz-User-Agent"
      }
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "accommodations_options_response" {
  depends_on    = [aws_api_gateway_integration.accommodations_options]
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.accommodations.id
  http_method   = aws_api_gateway_method.accommodations_options.http_method
  status_code   = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "accommodations_options_response" {
  depends_on              = [aws_api_gateway_integration.accommodations_options]
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_resource.accommodations.id
  http_method             = aws_api_gateway_method.accommodations_options.http_method
  status_code             = "200"
  response_templates      = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS, GET'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token, X-Amz-User-Agent'"
  }
}

resource "aws_api_gateway_deployment" "accommodations_deployment" {
  depends_on  = [
    aws_api_gateway_integration.accommodations_get_lambda,
    aws_api_gateway_integration.accommodations_options
  ]
  rest_api_id = var.api_gateway_id
  stage_name  = "dev"
  triggers = {
    redeployment = sha1(
      jsonencode(
        merge(
          aws_api_gateway_integration.accommodations_get_lambda,
          aws_api_gateway_integration.accommodations_options
        )
      )
    )
  }
  lifecycle {
    create_before_destroy = true
  }
}
