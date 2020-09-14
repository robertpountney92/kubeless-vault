// resource "google_kms_key_ring" "vault" {
//   project  = var.project_id
//   name     = var.key_ring
//   location = var.region
// }

// resource "google_kms_crypto_key" "vault-init" {
//   name     = var.crypto_key
//   key_ring = google_kms_key_ring.vault.self_link
// }

// resource "google_kms_key_ring_iam_binding" "vault-init" {
//   key_ring_id = google_kms_key_ring.vault.id
//   role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
//   members = [
//     "serviceAccount:${var.service_account_id}@${var.project_id}.iam.gserviceaccount.com",
//   ]
// }
