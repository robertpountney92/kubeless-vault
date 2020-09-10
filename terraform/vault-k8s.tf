data "local_file" "gcp_service_acct_creds_local" {
  filename = var.gcp_service_acct_creds_local
}

resource "kubernetes_secret" "kms-creds" {
  depends_on = [google_container_cluster.primary]
  metadata {
    name      = "kms-creds"
    namespace = "default"
  }

  data = {
    "credentials.json" = data.local_file.gcp_service_acct_creds_local.content
  }

  type = "Opaque"
}

resource "helm_release" "vault" {
  depends_on = [google_container_cluster.primary]
  name  = "vault"
  chart = "hashicorp/vault"
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
