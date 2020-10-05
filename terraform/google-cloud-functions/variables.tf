variable "VAULT_ADDR" {
  description = "Load balancer address for vault cluster"
}

variable "service_account_id_verifier" {
  description = "Service account for Vault to comminicate with Google Cloud API"
  default     = "vault-verifier"
}

variable "service_account_id_auther" {
  description = "Service account which will be attached to the Cloud Function at boot"
  default     = "vault-auther"
}

variable "apikey1" {
  description = "An API key to interact with an external system"
  default     = "an-example-api-key"
}