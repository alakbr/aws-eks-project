resource "aws_secretsmanager_secret" "retailstore_db" {
  name        = "retailstore-db-secret-1"
  description = "RetailStore MySQL database credentials"

  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "retailstore_secret_value" {
  secret_id = aws_secretsmanager_secret.retailstore_db.id

  secret_string = jsonencode({
    username = "mydbadmin"
    password = "kalyandb101"
  })
}
