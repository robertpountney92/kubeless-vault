// output "region" {
//     value = var.region
// }

// output "gke_cluster_name" {
//   value = data.google_container_cluster.my_cluster.name
// }

// output "vault_lb_endpoint" {
//   value = "http://${data.kubernetes_service.vault_lb.load_balancer_ingress[0].ip}:8200"
// }

output "key_decode" {
  value = base64decode(google_service_account_key.vault-verifier-key.private_key)
}

output "auth_path" {
  value = vault_gcp_auth_backend.gcp.path
}