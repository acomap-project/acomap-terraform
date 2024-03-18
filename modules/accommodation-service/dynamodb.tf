
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
    name = "cityCode"
    type = "S"
  }

  attribute {
    name = "areaCode"
    type = "S"
  }

  global_secondary_index {
    hash_key           = "cityCode"
    range_key          = "areaCode"
    name               = "city_code-area_code-index"
    non_key_attributes = []
    projection_type    = "ALL"
    read_capacity      = 4
    write_capacity     = 1
  }

  ttl {
    attribute_name = "expiredAt"
    enabled = true
  }

  tags = {
    Service = "ACCOM"
    Project = "acomap-project"
  }
}