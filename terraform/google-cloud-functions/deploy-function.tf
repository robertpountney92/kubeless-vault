# Deploy Google Cloud Function
# zip up our source code
data "archive_file" "apikey-zip" {
 type        = "zip"
 source_dir  = "${path.root}/python/"
 output_path = "${path.root}/apikey.zip"
}

# create the storage bucket
resource "google_storage_bucket" "apikey-bucket" {
 name   = "apikey-bucket"
}

# place the zipped code in the bucket
resource "google_storage_bucket_object" "apikey-zip" {
 name   = "apikey.zip"
 bucket = google_storage_bucket.apikey-bucket.name
 source = "${path.root}/apikey.zip"
}

# Creating the Cloud Function
resource "google_cloudfunctions_function" "apikey-function" {
  name                  = "apikey-function"
  description           = "Function to retrieve API key from HashiCorp Vault"
//  available_memory_mb   = 256
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


// gcloud beta functions deploy vault-serverless-gcloud \
//     --source ./functions \
//     --runtime python37 \
//     --entry-point F \
//     --service-account vault-auther@${GOOGLE_PROJECT}.iam.gserviceaccount.com \
//     --set-env-vars VAULT_ADDR=${VAULT_ADDR} \
//     --trigger-http

// gcloud beta functions deploy vault-serverless \
//     --source ./python \
//     --runtime python37 \
//     --entry-point F \
//     --service-account app1-vault-auther@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
//     --set-env-vars VAULT_ADDR=${VAULT_ADDR} \
//     --trigger-http