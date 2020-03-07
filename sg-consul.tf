resource "google_service_account" "consul_sg" {
  account_id  = var.consul_sg_name
  description = "${var.consul_sg_name} service account"
  count       = var.consul_enabled ? 1 : 0
}

resource "google_compute_firewall" "consul_sg_ssh" {
  name          = "${var.consul_sg_name}-ssh"
  network       = google_compute_network.vpc_network.name
  count         = var.consul_enabled && var.bastion_enabled ? 0 : 1
  description   = "${var.consul_sg_name} SSH access from corporate IP"
  direction     = "INGRESS"
  source_ranges = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "consul_sg_bastion_ssh" {
  name                    = "${var.consul_sg_name}-ssh"
  network                 = google_compute_network.vpc_network.name
  count                   = var.bastion_enabled ? 1 : 0
  description             = "${var.consul_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.bastion_sg[*].unique_id]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "consul_sg_mon_prom" {
  name                    = "${var.consul_sg_name}-monitoring"
  network                 = google_compute_network.vpc_network.name
  count                   = var.consul_enabled && var.monitoring_enabled ? 1 : 0
  description             = "${var.consul_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
    "9100"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "consul_sg_mon_nordstrom" {
  name                    = "${var.consul_sg_name}-monitoring"
  network                 = google_compute_network.vpc_network.name
  count                   = var.consul_enabled && ! var.monitoring_enabled ? 1 : 0
  description             = "${var.consul_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
    "9428"]
    protocol = "tcp"
  }
}