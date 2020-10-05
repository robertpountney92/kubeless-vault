resource "google_service_account" "vault-server" {
  account_id   = var.service_account_id
  display_name = "Vault service account - provisioned by Terraform"
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.vault-server.name
}