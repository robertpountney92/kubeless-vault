// variable "project_id" {
//   description = "project id"
// }

// variable "region" {
//   description = "region"
// }

// variable "credentials" {
//   description = "Path to GCP credentials file"
//   default = "~/.config/gcloud/application_default_credentials.json"
// }

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

// variable "gcp_service_list" {
//   description = "List of GCP service to be enabled for a project."
//   type        = list
//   default = [
//     "compute.googleapis.com", # Compute Engine API
//     "iam.googleapis.com",     # Identity and Access Management (IAM) API
//   ]
// }