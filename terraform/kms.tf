resource "google_kms_key_ring" "vault" {
  project  = var.project_id
  name     = var.key_ring
  location = var.region
}

resource "google_kms_crypto_key" "vault-init" {
  name     = var.crypto_key
  key_ring = google_kms_key_ring.vault.self_link
}

resource "google_service_account" "vault-server" {
  account_id   = var.service_account_id
  display_name = "Vault service account - provisioned by Terraform"
}

resource "google_kms_key_ring_iam_binding" "vault-init" {
  key_ring_id = google_kms_key_ring.vault.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${var.service_account_id}@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.vault-server.name
}

// resource "kubernetes_secret" "google-application-credentials" {
//   metadata {
//     name = "google-application-credentials"
//   }
//   data = {
//     "credentials.json" = base64decode(google_service_account_key.mykey.private_key)
//   }
// }