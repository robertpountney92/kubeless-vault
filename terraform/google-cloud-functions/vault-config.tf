# Mount kv secrets engine at path "secret"
resource "vault_mount" "kv" {
  path = "secret"
  type = "kv"
  description = "Mount KV secrets engine at path secret"
}

# Add API key secret to vault 
resource "vault_generic_secret" "apikey1" {
  path = "secret/apikeys/apikey1"

  data_json = <<EOT
{
  "value":   "${var.apikey1}"
}
EOT
}

# Enable GCP auth bakend in vault
resource "vault_gcp_auth_backend" "gcp" {
    credentials  = base64decode(google_service_account_key.vault-verifier-key.private_key)
}

# Create policy that grants read access to API key
resource "vault_policy" "apikey1" {
  name = "apikey1"

  policy = <<EOT
path "secret/apikeys/apikey1" {
  capabilities = ["read"]
}
EOT
}

# Create a GCP role in vault that permits auther service account to authenticate to Vault
# The auther service account is the one that is attached to the deployed cloud function
resource "vault_gcp_auth_backend_role" "apikey1" {
    role                   = "apikey1"
    type                   = "iam"
    backend                = vault_gcp_auth_backend.gcp.path
    bound_projects         = [data.google_client_config.current.project]
    token_policies         = [vault_policy.apikey1.name]
    bound_service_accounts = ["${var.service_account_id_auther}@${data.google_client_config.current.project}.iam.gserviceaccount.com"]
    max_jwt_exp            = "60m"
}