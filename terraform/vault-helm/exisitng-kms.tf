data "google_kms_key_ring" "vault" {
  count = var.existing_kms ? 1 : 0

  name     = var.key_ring
  location = "us-central1"
}

resource "google_kms_key_ring_iam_binding" "vault-init" {
  count = var.existing_kms ? 1 : 0

  key_ring_id = data.google_kms_key_ring.vault[0].self_link
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${var.service_account_id}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
  ]
}