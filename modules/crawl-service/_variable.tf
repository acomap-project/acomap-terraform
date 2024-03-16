variable "api_gateway_id" {
  description = "The ID of the API Gateway"
}

variable "api_gateway_execution_arn" {
  description = "The ARN of the API Gateway execution"
}

variable "api_gateway_root_resource_id" {
  description = "The ID of the root resource of the API Gateway"
}

variable "accom_service_sqs_arn" {
  description = "SQS ARN to send the message to accommodation service"
  type        = string
}

variable "accom_service_sqs_url" {
    description = "SQS ARN to send the message to accommodation service"
    type        = string
}