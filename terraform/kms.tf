// resource "google_kms_key_ring" "vault" {
//   project  = var.project_id
//   name     = "${var.prefix}-vault"
//   location = var.region
// }

// resource "google_kms_crypto_key" "vault-init" {
//   name     = "${var.prefix}-vault-init"
//   key_ring = google_kms_key_ring.vault.self_link
// }

// resource "google_service_account" "vault-server" {
//   account_id   = "${var.prefix}-vault-server"
//   display_name = "vault service account"
// }

// resource "google_kms_key_ring_iam_binding" "vault-init" {
//   key_ring_id = google_kms_key_ring.vault.id
//   role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
//   members = [
//     "serviceAccount:${var.prefix}-vault-server@${var.project_id}.iam.gserviceaccount.com",
//   ]
// }