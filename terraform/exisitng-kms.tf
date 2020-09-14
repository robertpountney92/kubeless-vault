data "google_kms_key_ring" "vault" {
  name     = var.key_ring
  location = "us-central1"
}

resource "google_kms_key_ring_iam_binding" "vault-init" {
  key_ring_id = data.google_kms_key_ring.vault.self_link
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${var.service_account_id}@${var.project_id}.iam.gserviceaccount.com",
  ]
}

