resource "aws_iam_role" "accom_listing_function_role" {
  name = "ACCOM_accom-listing-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  // add managed policy for lambda
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}


resource "aws_iam_role" "accom_management_function_role" {
  name = "ACCOM_accom-management-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  // add managed policy for lambda
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}

