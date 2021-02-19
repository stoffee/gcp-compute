provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  credentials = var.gcp_credentials
}

variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
}

variable "gcp_credentials" {
  description = "The GCP credentials json"
}

variable "gcp_region" {
  description = "The region in which all GCP resources will be launched."
}

variable "gcp_zone" {
  description = "The region in which all GCP resources will be launched."
}

variable "instance_type" {
  description = "The instance type"
}


resource "random_pet" "server" {}

resource "google_compute_firewall" "allow-inbound" {
  name    = "allow-inbound"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080","3000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "default" {
  name         = random_pet.server.id
  machine_type = var.instance_type
  zone         = var.gcp_zone

  tags = ["ttl", "24"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    TTL = "24"
  }

  metadata_startup_script = <<SCRIPT
  sudo apt update
  SCRIPT
}