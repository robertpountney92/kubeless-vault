# Enable APIs to interact with GCP services
// resource "google_project_service" "gcp_services" {
//   count   = length(var.gcp_service_list)
//   project = data.google_client_config.current.project
//   service = var.gcp_service_list[count.index]

//   disable_dependent_services = true
//   disable_on_destroy = false
// }