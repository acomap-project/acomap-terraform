resource "aws_sqs_queue" "acom_queue" {
    name                      = "ACCOM_accommodation-queue"
    fifo_queue                = false
    tags = {
        Service = "ACCOM"
        Project = "acomap-project"
    }
}

output "accommodation_queue_url" {
    value = aws_sqs_queue.acom_queue.url
}

output "accommodation_queue_arn" {
    value = aws_sqs_queue.acom_queue.arn
}