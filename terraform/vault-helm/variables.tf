// variable "project_id" {
//   description = "GCP project id"
// }

// variable "region" {
//   description = "GCP region"
// }

// variable "credentials" {
//   description = "Path to GCP credentials file"
//   default = "~/.config/gcloud/application_default_credentials.json"
// }

// variable "gcp_service_list" {
//   description = "List of GCP service to be enabled for a project."
//   type        = list
//   default = [
//     "cloudkms.googleapis.com", # KMS API
//     "iam.googleapis.com",      # Identity and Access Management (IAM) API
//   ]
// }

variable "gcp_service_acct_creds_k8s" {
  description = "Path to service account credentials file to connect to gcloud from within k8s cluster"
  default     = "/vault/userconfig/kms-creds/credentials.json"
}

variable "service_account_id" {
  description = "Service account name"
  default     = "vault-server"
}

variable "key_ring" {
  description = "Key ring name"
  default     = "vault"
}

variable "crypto_key" {
  description = "Individual key name within key ring"
  default     = "vault-init"
}

variable "existing_kms" {
  description = "Do we have an existing kms key used for vault auto-unseal?"
  type        = bool
  default     = true
}