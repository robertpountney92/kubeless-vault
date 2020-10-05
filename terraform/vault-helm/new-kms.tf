resource "google_kms_key_ring" "vault" {
  count = var.existing_kms ? 0 : 1

  project  = data.google_client_config.current.project
  name     = var.key_ring
  location = data.google_client_config.current.region
}

resource "google_kms_crypto_key" "vault-init" {
  count = var.existing_kms ? 0 : 1

  name     = var.crypto_key
  key_ring = google_kms_key_ring.vault[0].self_link
}

resource "google_kms_key_ring_iam_binding" "vault-init-new" {
  count = var.existing_kms ? 0 : 1

  key_ring_id = google_kms_key_ring.vault[0].id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${var.service_account_id}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
  ]
}
