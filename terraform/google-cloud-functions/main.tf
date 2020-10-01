resource "google_service_account" "vault-verifier" {
  account_id   = var.service_account_id_verifier
  display_name = "Service account for Vault to comminicate with Google Cloud API"
}

resource "google_service_account_key" "vault-verifier-key" {
  service_account_id = google_service_account.vault-verifier.name
}

# Grant the service account the ability to verify other service accounts
resource "google_service_account_iam_binding" "vault-verifier-iam" {
  service_account_id = google_service_account.vault-verifier.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.service_account_id_verifier}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
  ]
}

resource "vault_mount" "kv" {
  path = "secret"
  type = "kv"
  description = "Mount KV secrets engine at path secret"
}

resource "vault_generic_secret" "apikey1" {
  path = "secret/apikeys/apikey1"

  data_json = <<EOT
{
  "value":   "${var.apikey1}"
}
EOT
}

// # Set to 1 minute because that is the default function timeout.
// # Set to 10 minutes because that is the maximum allowed function execution time
// resource "vault_auth_backend" "gcp" {
//   type = "gcp"

//   tune {
//     default_lease_ttl  = "1m" 
//     max_lease_ttl      = "10m" 
//   }
// }

resource "vault_gcp_auth_backend" "gcp" {
    credentials  = base64decode(google_service_account_key.vault-verifier-key.private_key)
}

resource "vault_policy" "apikey1" {
  name = "apikey1"

  policy = <<EOT
path "secret/apikeys/apikey1" {
  capabilities = ["read"]
}
EOT
}

resource "google_service_account" "vault-auther" {
  account_id   = var.service_account_id_auther
  display_name = "Service account which will be attached to the Cloud Function at boot"
}

resource "vault_gcp_auth_backend_role" "apikey1" {
    role                   = "apikey1"
    type                   = "iam"
    backend                = vault_gcp_auth_backend.gcp.path
    bound_projects         = [data.google_client_config.current.project]
    bound_service_accounts = ["${var.service_account_id_auther}@${data.google_client_config.current.project}.iam.gserviceaccount.com"]
    max_jwt_exp            = "60m"
}

# Deploy Google Cloud Function
# zip up our source code
data "archive_file" "apikey_zip" {
 type        = "zip"
 source_dir  = "${path.root}/functions/"
 output_path = "${path.root}/apikey.zip"
}

# create the storage bucket
resource "google_storage_bucket" "apikey_bucket" {
 name   = "apikey_bucket"
}

# place the zipped code in the bucket
resource "google_storage_bucket_object" "apikey_zip" {
 name   = "apikey.zip"
 bucket = google_storage_bucket.apikey_bucket.name
 source = "${path.root}/apikey.zip"
}

# Creating the Cloud Function
resource "google_cloudfunctions_function" "apikey_function" {
  name                  = "apikey-function"
  description           = "Function to retrieve API key from HashiCorp Vault"
//  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.apikey_bucket.name
  source_archive_object = google_storage_bucket_object.apikey_zip.name
  timeout               = 60
  entry_point           = "F"
  trigger_http          = true
  runtime               = "python37"
  service_account_email = "${var.service_account_id_auther}@${data.google_client_config.current.project}.iam.gserviceaccount.com"
  environment_variables = {
    VAULT_ADDR = "${var.vault_address}"
  }
}

