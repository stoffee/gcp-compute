resource "google_compute_instance" "default" {
  name         = "${random_pet.server.id}-buildly"
  machine_type = var.instance_type
  zone         = var.gcp_zone

  tags = ["mission", "buildly"]

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
    Mission = "buildly"
  }

  metadata_startup_script = <<SCRIPT
  sudo apt update
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  sudo apt update
  apt-cache policy docker-ce
  sudo apt install -y docker-ce 
  sudo systemctl status docker
  SCRIPT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}