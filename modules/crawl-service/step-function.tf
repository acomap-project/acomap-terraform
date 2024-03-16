

resource "aws_sfn_state_machine" "crawl-workflow" {
    name     = "CRAWL_crawl-workflow"
    role_arn = aws_iam_role.crawl-workflow-role.arn
    tags = {
        Service = "CRAWL"
        Project = "acomap-project"
    }
    definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Map each area",
  "States": {
    "Map each area": {
      "Type": "Map",
      "ItemProcessor": {
        "ProcessorConfig": {
          "Mode": "INLINE"
        },
        "StartAt": "Crawl accommodation",
        "States": {
          "Crawl accommodation": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "OutputPath": "$.Payload",
            "Parameters": {
              "FunctionName": "${aws_lambda_function.crawl-function.arn}",
              "Payload.$": "$"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException",
                  "Lambda.TooManyRequestsException"
                ],
                "IntervalSeconds": 1,
                "MaxAttempts": 3,
                "BackoffRate": 2
              }
            ],
            "Next": "Map each accommodation",
            "Catch": [
              {
                "ErrorEquals": [
                  "States.TaskFailed"
                ],
                "Next": "Cannot crawl accommodation"
              }
            ]
          },
          "Cannot crawl accommodation": {
            "Type": "Pass",
            "End": true
          },
          "Map each accommodation": {
            "Type": "Map",
            "ItemProcessor": {
              "ProcessorConfig": {
                "Mode": "INLINE"
              },
              "StartAt": "Choice",
              "States": {
                "Choice": {
                  "Type": "Choice",
                  "Choices": [
                    {
                      "Variable": "$.isLocationResolved",
                      "BooleanEquals": false,
                      "Next": "Save raw accom"
                    }
                  ],
                  "Default": "Save resolved accom"
                },
                "Save raw accom": {
                  "Type": "Task",
                  "Resource": "arn:aws:states:::lambda:invoke",
                  "OutputPath": "$.Payload",
                  "Parameters": {
                    "FunctionName": "${aws_lambda_function.raw-accom-function.arn}",
                    "Payload": {
                      "accom.$": "$"
                    }
                  },
                  "Retry": [
                    {
                      "ErrorEquals": [
                        "Lambda.ServiceException",
                        "Lambda.AWSLambdaException",
                        "Lambda.SdkClientException",
                        "Lambda.TooManyRequestsException"
                      ],
                      "IntervalSeconds": 1,
                      "MaxAttempts": 3,
                      "BackoffRate": 2
                    }
                  ],
                  "End": true
                },
                "Save resolved accom": {
                  "Type": "Task",
                  "Resource": "arn:aws:states:::sqs:sendMessage",
                  "Parameters": {
                    "MessageBody.$": "$",
                    "QueueUrl": "${var.accom_service_sqs_url}"
                  },
                  "End": true
                }
              }
            },
            "End": true,
            "InputPath": "$.item_list"
          }
        }
      },
      "ItemsPath": "$.area_list",
      "ResultSelector": {
        "results.$": "$"
      },
      "End": true
    }
  }
}
EOF
}