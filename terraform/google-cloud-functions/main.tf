resource "google_service_account" "vault-verifier" {
  account_id   = var.service_account_id_verifier
  display_name = "Service account for Vault to comminicate with Google Cloud API"
}

resource "google_service_account_key" "vault-verifier-key" {
  service_account_id = google_service_account.vault-verifier.name
}

# Grant the service account the ability to verify other service accounts
// resource "google_service_account_iam_binding" "vault-verifier-iam" {
//   service_account_id = google_service_account.vault-verifier.name
//   role               = "roles/iam.serviceAccountUser"

//   members = [
//     "serviceAccount:${var.service_account_id_verifier}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
//   ]
// }


# Grant the service account the ability to verify other service accounts
resource "google_project_iam_binding" "vault-verifier-iam" {
  project = data.google_client_config.current.project
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.service_account_id_verifier}@${data.google_client_config.current.project}.iam.gserviceaccount.com",
  ]
}

resource "vault_mount" "kv" {
  path = "secret"
  type = "kv"
  description = "Mount KV secrets engine at path secret"
}

resource "vault_generic_secret" "twitter" {
  depends_on = [vault_mount.kv] 

  path = "secret/apikeys/twitter"

  data_json = <<EOT
{
  "value":   "${var.twitter}"
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

resource "vault_policy" "apikey-twitter" {
  name = "apikey-twitter"

  policy = <<EOT
path "secret/apikeys/twitter" {
  capabilities = ["read"]
}
EOT
}

resource "google_service_account" "vault-auther" {
  account_id   = var.service_account_id_auther
  display_name = "Service account which will be attached to the Cloud Function at boot"
}

resource "vault_gcp_auth_backend_role" "socialmedia" {
    role                   = "socialmedia"
    type                   = "iam"
    backend                = vault_gcp_auth_backend.gcp.path
    bound_projects         = [data.google_client_config.current.project]
    token_policies         = [vault_policy.apikey-twitter.name]
    bound_service_accounts = ["${var.service_account_id_auther}@${data.google_client_config.current.project}.iam.gserviceaccount.com"]
    max_jwt_exp            = "60m"
}