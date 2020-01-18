resource "google_compute_firewall" "allow-inbound" {
  name    = "allow-inbound"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080","3000"]
  }

  source_ranges = ["0.0.0.0/0"]
}