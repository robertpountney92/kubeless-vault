# Arguments for this provider are defined by Environment Varibales
provider "google" {
}

# Access the configuration of the Google Cloud provider
data "google_client_config" "current" {}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../gke-cluster/terraform.tfstate"
  }
}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.google_client_config.current.region
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

provider "local" {
}