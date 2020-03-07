resource "google_service_account" "vault_sg" {
  account_id  = var.vault_sg_name
  description = "${var.vault_sg_name} service account"
  count       = var.vault_enabled ? 1 : 0
}

resource "google_compute_firewall" "vault_sg_various" {
  name                    = "${var.vault_sg_name}-various"
  network                 = google_compute_network.vpc_network.name
  count                   = var.vault_enabled ? 1 : 0
  description             = "${var.vault_sg_name} various ports"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.vault_sg[*].unique_id]

  allow {
    ports = [
      "8200",
    "8201"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "vault_sg_ssh" {
  name          = "${var.vault_sg_name}-ssh"
  network       = google_compute_network.vpc_network.name
  count         = var.vault_enabled && ! var.bastion_enabled ? 1 : 0
  description   = "${var.vault_sg_name} SSH access from corporate IP"
  direction     = "INGRESS"
  source_ranges = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "vault_sg_bastion_ssh" {
  name                    = "${var.vault_sg_name}-ssh"
  network                 = google_compute_network.vpc_network.name
  count                   = var.vault_enabled && var.bastion_enabled ? 1 : 0
  description             = "${var.vault_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.bastion_sg[*].unique_id]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "vault_sg_mon" {
  name                    = "${var.vault_sg_name}-monitoring"
  network                 = google_compute_network.vpc_network.name
  count                   = var.vault_enabled && var.monitoring_enabled ? 1 : 0
  description             = "${var.logging_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
      "9100",
    "9333"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "vault_sg_consul" {
  name                    = "${var.vault_sg_name}-consul"
  network                 = google_compute_network.vpc_network.name
  description             = "${var.vault_sg_name} Consul ports"
  count                   = var.vault_enabled && var.consul_enabled ? 1 : 0
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.consul_sg[*].unique_id]

  allow {
    ports = [
      "8600",
      "8500",
      "8301",
    "8302"]
    protocol = "tcp"
  }

  allow {
    ports = [
      "8600",
      "8301",
    "8302"]
    protocol = "udp"
  }
}