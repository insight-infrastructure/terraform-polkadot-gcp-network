resource "google_service_account" "monitoring_sg" {
  account_id  = var.monitoring_sg_name
  description = "${var.monitoring_sg_name} service account"
  count       = var.monitoring_enabled ? 1 : 0
}

resource "google_compute_firewall" "monitoring_sg_http_ingress" {
  name                    = "${var.monitoring_sg_name}-http-ingress"
  network                 = google_compute_network.vpc_network.name
  description             = "${var.monitoring_sg_name} HTTP ingress"
  count                   = var.monitoring_enabled ? 1 : 0
  direction               = "INGRESS"
  target_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
    "80"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_ssh" {
  name                    = "${var.monitoring_sg_name}-ssh"
  network                 = google_compute_network.vpc_network.name
  count                   = var.bastion_enabled ? 0 : 1
  description             = "${var.monitoring_sg_name} SSH access from corporate IP"
  direction               = "INGRESS"
  source_ranges           = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]
  target_service_accounts = google_service_account.monitoring_sg[*].unique_id

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_bastion_ssh" {
  name                    = "${var.monitoring_sg_name}-ssh"
  network                 = google_compute_network.vpc_network.name
  count                   = var.bastion_enabled ? 1 : 0
  description             = "${var.bastion_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.bastion_sg[*].unique_id]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_consul" {
  name                    = "${var.monitoring_sg_name}-consul"
  network                 = google_compute_network.vpc_network.name
  description             = "${var.monitoring_sg_name} Consul ports"
  count                   = var.monitoring_enabled && var.consul_enabled ? 1 : 0
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