
resource "aws_dynamodb_table" "accommodation" {
  name           = "ACCOM_accommodation"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "source"
  range_key      = "id"

  attribute {
    name = "source"
    type = "S"
  }
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "price"
    type = "N"
  }
  attribute {
    name = "publishedDate"
    type = "S"
  }

  global_secondary_index {
    hash_key           = "publishedDate"
    name               = "publishedDate-price-index"
    non_key_attributes = []
    projection_type    = "ALL"
    range_key          = "price"
    read_capacity      = 4
    write_capacity     = 1
  }

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}