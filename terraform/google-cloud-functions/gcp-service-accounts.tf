# Service account for Vault to comminicate with Google Cloud API
resource "google_service_account" "vault-verifier" {
  account_id   = var.service_account_id_verifier
  display_name = "Service account for Vault to comminicate with Google Cloud API"
}

# Create credentials key file for service account
resource "google_service_account_key" "vault-verifier-key" {
  service_account_id = google_service_account.vault-verifier.name
}

# Grant the service account the ability to verify other service accounts
resource "google_project_iam_binding" "vault-verifier-iam" {
  project = data.google_client_config.current.project
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.service_account_id_verifier}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
  ]
}

# Service account which will be attached to the Cloud Function at boot
resource "google_service_account" "vault-auther" {
  account_id   = var.service_account_id_auther
  display_name = "Service account which will be attached to the Cloud Function at boot"
}