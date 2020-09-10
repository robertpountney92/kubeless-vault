// resource "kubernetes_role_binding" "token" {
//   depends_on = [google_container_cluster.primary, module.kubernetes_dashboard]

//   metadata {
//     name      = "admin-user"
//   }
//   role_ref {
//     api_group = "rbac.authorization.k8s.io"
//     kind      = "ClusterRole"
//     name      = "cluster-admin"
//   }
//   subject {
//     kind      = "ServiceAccount"
//     name      = "admin-user"
//     namespace = "kube-system"
//   }
// }

// data "kubernetes_service_account" "token" {
//   depends_on = [kubernetes_role_binding.token] 

//   metadata {
//     name = "service-controller"
//     namespace = "kube-system"
//   }
// }

// data "kubernetes_secret" "token" {
//   metadata {
//     name = "${data.kubernetes_service_account.token.default_secret_name}"
//     namespace = "kube-system"
//   }
// }

// output "kubernetes_dashboard_token_data" {
//   value = data.kubernetes_secret.token.data
// }