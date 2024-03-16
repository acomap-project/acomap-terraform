resource "aws_lambda_function" "crawl-function" {
  function_name = "CRAWL_crawl-function"
  runtime       = "nodejs18.x"
  // use static/default_lambda.zip as the source code
  filename = "static/default_lambda.zip"
  handler  = "dist/lambda.handler"
  role     = aws_iam_role.lambda-function-role.arn
  timeout  = 120

  lifecycle {
    ignore_changes = [environment]
  }

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}

resource "aws_lambda_function" "map-function" {
  function_name = "CRAWL_map-function"
  runtime       = "nodejs18.x"
  // use static/default_lambda.zip as the source code
  filename = "static/default_lambda.zip"
  handler  = "dist/lambda.handler"
  role     = aws_iam_role.lambda-function-role.arn
  timeout  = 120

  lifecycle {
    ignore_changes = [environment]
  }

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}

resource "aws_lambda_function" "raw-accom-function" {
  function_name = "CRAWL_raw-accom-function"
  runtime       = "nodejs18.x"
  // use static/default_lambda.zip as the source code
  filename = "static/default_lambda.zip"
  handler  = "dist/lambda.handler"
  role     = aws_iam_role.lambda-function-role.arn
  timeout  = 10

  lifecycle {
    ignore_changes = [environment]
  }

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}

# create a resource-based policy statement for the lambda function to allow Step Function to invoke it
resource "aws_lambda_permission" "crawl-function-permission" {
  statement_id  = "AllowExecutionFromStepFunctions_CRAWL_crawl-function"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crawl-function.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.crawl-workflow.arn
}


# create a resource-based policy statement for the map-function to allow Step Function to invoke it
resource "aws_lambda_permission" "map-function-permission" {
  statement_id  = "AllowExecutionFromStepFunctions_CRAWL_map-function"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.map-function.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.crawl-workflow.arn
}

resource "aws_lambda_permission" "raw-accom-permission" {
  statement_id  = "AllowExecutionFromStepFunctions_CRAWL_raw-function"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.raw-accom-function.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.crawl-workflow.arn
}

resource "aws_lambda_permission" "raw-accom-apigateway-permission" {
  statement_id  = "AllowExecutionFromApiGateway_CRAWL_raw-accom-function"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.raw-accom-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*"
}

output "lambda_function_arns" {
  value = [
    aws_lambda_function.crawl-function.arn,
    aws_lambda_function.map-function.arn,
    aws_lambda_function.raw-accom-function.arn
  ]
}


