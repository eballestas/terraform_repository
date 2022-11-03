resource "random_integer" "random_id" {
  min = 10000
  max = 99999
}

locals {
  bucket_name = "${random_integer.random_id.result}-tf-backend"
  location    = "us-central1"
}
