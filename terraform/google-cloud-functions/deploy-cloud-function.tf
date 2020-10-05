# Deploy Google Cloud Function
# Zip up our source code
data "archive_file" "apikey-zip" {
 type        = "zip"
 source_dir  = "${path.root}/functions/"
 output_path = "${path.root}/apikey.zip"
}

# Create the storage bucket
resource "google_storage_bucket" "apikey-bucket" {
 name   = "apikey-bucket"
}

# Place the zipped code in the bucket
resource "google_storage_bucket_object" "apikey-zip" {
 name   = "apikey.zip"
 bucket = google_storage_bucket.apikey-bucket.name
 source = "${path.root}/apikey.zip"
}

# Creating the Cloud Function
resource "google_cloudfunctions_function" "apikey-function" {
  name                  = "apikey"
  description           = "Function to retrieve API key from HashiCorp Vault"
  source_archive_bucket = google_storage_bucket.apikey-bucket.name
  source_archive_object = google_storage_bucket_object.apikey-zip.name
  timeout               = 60
  entry_point           = "F"
  trigger_http          = true
  runtime               = "python37"
  service_account_email = "${var.service_account_id_auther}@${data.google_client_config.current.project}.iam.gserviceaccount.com"
  environment_variables = {
    VAULT_ADDR = "${var.VAULT_ADDR}" # Set via TF_VAR_VAULT_ADDR environment variable
  }
}