resource "aws_dynamodb_table" "terraform_state_lock" {
  for_each = local.aws_nosql_default

  name         = each.key
  hash_key     = "LockID"
  billing_mode = each.value.billing_mode

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    { "Name" = each.key }
  )

}
