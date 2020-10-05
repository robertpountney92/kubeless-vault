# VPC
resource "google_compute_network" "vpc" {
  name                    = "${data.google_client_config.current.project}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${data.google_client_config.current.project}-subnet"
  region        = data.google_client_config.current.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}