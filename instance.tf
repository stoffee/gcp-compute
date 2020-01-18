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
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo touch /etc/apt/sources.list.d/kubernetes.list
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update
  apt-cache policy docker-ce
  sudo apt install -y docker-ce docker-compose mosquitto mosquitto-clients kubectl nodejs npm
  npm install -g gulp
  sudo systemctl status docker
  sudo chmod a+w /usr/local/src
  cd /usr/local/src
  git clone https://github.com/buildlyio/buildly-core.git
  git clone https://github.com/Buildly-Marketplace/iot_service.git
  git clone --recurse-submodules https://github.com/buildlyio/buildly-cli.git
  git clone https://github.com/buildlyio/buildly-ui-react.git
  cd /usr/local/src/buildly-core
  sudo docker-compose build && sudo docker-compose up -d &
  cd /usr/local/src/buildly-ui-react
  sudo yarn install
  sudo yarn run init
  sudo yarn run build
  sudo yarn run start
  cd /usr/local/src/iot_service
  sudo docker-compose build && sudo docker-compose up -d &
  cd ../
  openssl genrsa -out private.pem 2048
  openssl rsa -in private.pem -outform PEM -pubout -out public.pem
  SCRIPT
}