// variable "project_id" {
//   description = "project id"
// }

// variable "region" {
//   description = "region"
// }

// variable "gcp_service_list" {
//   description = "List of GCP service to be enabled for a project."
//   type        = list
//   default = [
//     "cloudfunctions.googleapis.com",  # Cloud Functions API
//     "iam.googleapis.com",             # Identity and Access Management (IAM) API
//     "cloudbuild.googleapis.com",      # Cloud Build API
//   ]
// }

variable "VAULT_ADDR" {
  description = "Load balancer address for vault cluster"
}

variable "service_account_id_verifier" {
  description = "Service account for Vault to comminicate with Google Cloud API"
  default     = "vault-verifier"
}

variable "service_account_id_auther" {
  description = "Service account which will be attached to the Cloud Function at boot"
  default     = "app1-vault-auther"
}

variable "twitter" {
  description = "An API key to interact with an external system"
  default     = "an-example-api-key"
}