variable "accom_service_sqs_arn" {
  description = "SQS ARN to send the message to accommodation service"
  type        = string
}
resource "aws_iam_role" "lambda-function-role" {
  name = "CRAWL_lambda-function-role"
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
  ]

  inline_policy {
    name = "DynamoDBReadWritePolicy"

    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Sid       = "AllowDynamoDBReadWrite",
          Effect    = "Allow",
          Action    = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem"
          ],
          Resource  = "${aws_dynamodb_table.raw_accom.arn}"
        }
      ]
    })
  }

  inline_policy {
    name = "SQSSendMessagePolicy"

    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Sid       = "AllowSQSSendMessage",
          Effect    = "Allow",
          Action    = [
            "sqs:SendMessage"
          ],
          Resource  = "${var.accom_service_sqs_arn}"
        }
      ]
    })
  }

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}


resource "aws_iam_role" "crawl-workflow-role" {
  name = "CRAWL_crawl-workflow-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}


resource "aws_iam_role" "crawl-scheduler-role" {
  name = "CRAWL_eventbridge-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.eventbridge-scheduler-trigger-policy.arn
  ]

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}

resource "aws_iam_policy" "eventbridge-scheduler-trigger-policy" {
  name        = "CRAWL_eventbridge-scheduler-trigger-policy"
  description = "IAM policy for EventBridge scheduler to trigger Step Function"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowEventBridgeToTriggerStepFunction",
        Effect    = "Allow",
        Action    = [
          "states:StartExecution"
        ],
        Resource  = "*"
      }
    ]
  })
}
