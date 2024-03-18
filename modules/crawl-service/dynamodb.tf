
resource "aws_dynamodb_table" "raw_accom" {
  name           = "CRAWL_raw-accommodation"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "_id"

  attribute {
    name = "_id"
    type = "S"
  }

  ttl {
    attribute_name = "expiredAt"
    enabled = true
  }

  tags = {
    Service = "CRAWL"
    Project = "acomap-project"
  }
}