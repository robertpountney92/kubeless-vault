// data "local_file" "gcp_service_acct_creds_local" {
//   filename = var.gcp_service_acct_creds_local
// }

// resource "kubernetes_secret" "kms-creds" {
//   depends_on = [google_container_cluster.primary]
//   metadata {
//     name      = "kms-creds"
//     namespace = "default"
//   }

//   data = {
//     "credentials.json" = data.local_file.gcp_service_acct_creds_local.content
//   }

//   type = "Opaque"
// }

resource "kubernetes_secret" "google-application-credentials" {
  depends_on = [google_container_cluster.primary]
  
  metadata {
    name      = "kms-creds"
    namespace = "default"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.mykey.private_key)
  }

}

resource "helm_release" "vault" {
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]
  name       = "vault"
  chart      = "hashicorp/vault"
  values = [
    "${file("values-raft.yaml")}"
  ]
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_REGION"
    value = var.region
  }
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_PROJECT"
    value = var.project_id
  }
  set {
    name  = "server.extraEnvironmentVars.GOOGLE_APPLICATION_CREDENTIALS"
    value = var.gcp_service_acct_creds_k8s
  }
  set {
    name = "server.extraEnvironmentVars.VAULT_GCPCKMS_SEAL_KEY_RING"
    value = var.key_ring
    // value = google_kms_key_ring.vault.name
  }
  set {
    name = "server.extraEnvironmentVars.VAULT_GCPCKMS_SEAL_CRYPTO_KEY"
    value = var.crypto_key
    // value = google_kms_crypto_key.vault-init.name
  }
}
// resource "null_resource" "cleanup_pvc0" {
//   provisioner "local-exec" {
//     when       = destroy
//     on_failure = continue
//     command    = "kubectl delete pvc data-vault-0"
//   }
// }
// resource "null_resource" "cleanup_pvc1" {
//   provisioner "local-exec" {
//     when       = destroy
//     on_failure = continue
//     command    = "kubectl delete pvc data-vault-1"
//   }
// }
// resource "null_resource" "cleanup_pvc2" {
//   provisioner "local-exec" {
//     when       = destroy
//     on_failure = continue
//     command    = "kubectl delete pvc data-vault-2"
//   }
// }
