terraform {
  backend "gcs" {
    bucket = "92641-tf-backend"
    prefix = "terraform/state"
  }
}