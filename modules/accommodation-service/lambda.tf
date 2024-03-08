resource "aws_lambda_function" "accom-listing-function" {
  function_name = "ACCOM_accom-listing-function"
  runtime       = "nodejs18.x"
  // use static/default_lambda.zip as the source code
  filename = "static/default_lambda.zip"
  handler  = "dist/lambda.handler"
  role     = aws_iam_role.accom_listing_function_role.arn
  timeout  = 120

  lifecycle {
    ignore_changes = [environment]
  }

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}


resource "aws_lambda_function" "accom-management-function" {
  function_name = "ACCOM_accom-management-function"
  runtime       = "nodejs18.x"
  // use static/default_lambda.zip as the source code
  filename = "static/default_lambda.zip"
  handler  = "dist/lambda.handler"
  role     = aws_iam_role.accom_management_function_role.arn
  timeout  = 10

  lifecycle {
    ignore_changes = [environment]
  }

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}

resource "aws_lambda_permission" "sqs_invoke_permission" {
  statement_id  = "AllowSQSInvoke_ACCOM_accom-management-function"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.accom-management-function.function_name
  principal     = "sqs.amazonaws.com"
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.acom_queue.arn
  function_name    = aws_lambda_function.accom-management-function.function_name
  batch_size       = 10
}