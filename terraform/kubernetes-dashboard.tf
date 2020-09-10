// provider "kubernetes" {
//   # your kubernetes provider config
// }

// module "kubernetes_dashboard" {
//   depends_on = [google_container_cluster.primary]  
//   source = "cookielab/dashboard/kubernetes"
//   version = "0.9.0"

//   kubernetes_namespace_create = true
//   kubernetes_dashboard_csrf = ""
// }