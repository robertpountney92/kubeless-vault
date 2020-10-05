resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name      = "kms-creds"
    namespace = "default"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.mykey.private_key)
  }
}

resource "helm_release" "vault" {
  name  = "vault"
  chart = "hashicorp/vault"
  values = [
    "${file("values-raft.yaml")}"
  ]
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_REGION"
    value = data.google_client_config.current.region
  }
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_PROJECT"
    value = data.google_client_config.current.project
  }
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_APPLICATION_CREDENTIALS"
    value = var.gcp_service_acct_creds_k8s
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_GCPCKMS_SEAL_KEY_RING"
    value = var.key_ring
    // value = google_kms_key_ring.vault.name
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_GCPCKMS_SEAL_CRYPTO_KEY"
    value = var.crypto_key
    // value = google_kms_crypto_key.vault-init.name
  }
}

data "kubernetes_service" "vault_lb" {
  depends_on = [helm_release.vault]

  metadata {
    name = "vault-ui"
  }
}