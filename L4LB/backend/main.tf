resource "google_storage_bucket" "default" {
  name     = local.bucket_name
  location = local.location

}