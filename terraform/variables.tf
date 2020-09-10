variable "prefix" {
  default     = "tf-"
  description = "project id"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

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

variable "gcp_service_acct_creds_local" {
  default = "credentials.json"
}

variable "gcp_service_acct_creds_k8s" {
  default = "/vault/userconfig/kms-creds/credentials.json"
}

variable "service_account_id" {
  default = "vault-server"
}

variable "key_ring" {
  default = "vault"
}

variable "crypto_key" {
  default = "vault-init"
}