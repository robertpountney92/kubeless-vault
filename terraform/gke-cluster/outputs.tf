output "project" {
  value = data.google_client_config.current.project
}

output "region" {
  value = data.google_client_config.current.region
}

// output "credentials" {
//   value = var.credentials
// }

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}