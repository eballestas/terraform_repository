# VPC
resource "google_compute_network" "network" {
  name                    = "${local.deployment_name}-network"
  provider                = google-beta
  auto_create_subnetworks = false
}

# backed subnets
resource "google_compute_subnetwork" "subnet-1" {
  name          = "${local.deployment_name}-subnet-1"
  provider      = google-beta
  ip_cidr_range = var.ip_cidr_range_1
  region        = var.deployment_region_1
  network       = google_compute_network.network.id
}

resource "google_compute_subnetwork" "subnet-2" {
  name          = "${local.deployment_name}-subnet-2"
  provider      = google-beta
  ip_cidr_range = var.ip_cidr_range_2
  region        = var.deployment_region_2
  network       = google_compute_network.network.id
}

# instance template
resource "google_compute_instance_template" "instance_template-1" {
  name         = "${local.deployment_name}-mig-template-2"
  provider     = google-beta
  machine_type = var.instance_size
  tags         = local.tags

  network_interface {
    network    = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.subnet-1.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      apt update -y
      apt install mtr curl wget traceroute -y
      
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}


# instance template
resource "google_compute_instance_template" "instance_template-2" {
  name         = "${local.deployment_name}-mig-template-1"
  provider     = google-beta
  machine_type = var.instance_size
  tags         = local.tags

  network_interface {
    network    = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.subnet-2.id #to change for for-each
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      apt update -y
      apt install mtr curl wget traceroute -y
      
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# MIG #to change for for-each
resource "google_compute_region_instance_group_manager" "mig-1" {
  name     = "${local.deployment_name}-mig1"
  provider = google-beta
  region   = var.deployment_region_1 
  version {
    instance_template = google_compute_instance_template.instance_template-1.id
    name              = "primary"
  }
  base_instance_name = "${local.deployment_name}-vm-1"
  target_size        = var.mig_target_size
}

# MIG #to change for for-each
resource "google_compute_region_instance_group_manager" "mig-2" {
  name     = "${local.deployment_name}-mig2"
  provider = google-beta
  region   = var.deployment_region_2
  version {
    instance_template = google_compute_instance_template.instance_template-2.id
    name              = "primary"
  }
  base_instance_name = "${local.deployment_name}-vm-2"
  target_size        = var.mig_target_size
}

# allow communication within the subnet
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "${local.deployment_name}-fw-allow-to-backends"
  provider      = google-beta
  direction     = "INGRESS"
  network       = google_compute_network.network.id
  source_ranges = [var.ip_cidr_range_1, var.ip_cidr_range_2]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

# allow SSH
resource "google_compute_firewall" "fw_ilb_ssh" {
  name      = "${local.deployment_name}-fw-ssh"
  provider  = google-beta
  direction = "INGRESS"
  network   = google_compute_network.network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

# allow TCP
resource "google_compute_firewall" "fw_ilb_tcp" {
  name      = "${local.deployment_name}-fw-tcp"
  provider  = google-beta
  direction = "INGRESS"
  network   = google_compute_network.network.id
  allow {
    protocol = "tcp"
  }
  target_tags   = ["allow-tcp"]
  source_ranges = ["0.0.0.0/0"]
}


# # test instance internal to GCP for testing from whitin GCP
# resource "google_compute_instance" "vm_test" {
#   name         = "${local.deployment_name}-internal-test-vm"
#   provider     = google-beta
#   zone         = var.deployment_zone_1
#   machine_type = var.instance_size
#   network_interface {
#     network    = google_compute_network.network.id
#     subnetwork = google_compute_subnetwork.subnet.id
#   }
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#     }
#   }
# }