provider "google" {

project = " devops-2024"

region = "us-central1"

zone = "us-central1-a"

}

# Create a VPC network

resource "google_compute_network" "vpc_network" {

name = "my-vpc"

auto_create_subnetworks = false

}

# Create a public subnet

resource "google_compute_subnetwork" "public_subnet" {

name = "public-subnet"

network = google_compute_network.vpc_network.id

ip_cidr_range = "10.0.1.0/24"

region = "us-central1"

}

# Create a private subnet

resource "google_compute_subnetwork" "private_subnet" {

name = "private-subnet"

network = google_compute_network.vpc_network.id

ip_cidr_range = "10.0.2.0/24"

region = "us-central1"

}

# Create a firewall rule to allow HTTP/HTTPS traffic

resource "google_compute_firewall" "allow-http-https" {

name = "allow-http-https"

network = google_compute_network.vpc_network.name

allow {

protocol = "tcp"

ports = ["80", "443"]

}

source_ranges = ["0.0.0.0/0"]

}

# Create a Compute Engine instance in the public subnet

resource "google_compute_instance" "web_server_instance" {

name = "web-server-instance"

machine_type = "e2-medium"

zone = "us-central1-a"

boot_disk {

initialize_params {

image = "debian-cloud/debian-11"

}

}

network_interface {

network = google_compute_network.vpc_network.name

subnetwork = google_compute_subnetwork.public_subnet.name

access_config {} # This is required to assign a public IP

}

metadata_startup_script = <<-EOF

#!/bin/bash

apt-get update

apt-get install -y nginx

systemctl start nginx

systemctl enable nginx

EOF

tags = ["http-server", "https-server"]

}

# Output the public IP address of the instance

output "instance_ip" {

  value= google_compute_instance.web_server_instance.network_interface[0].access_config[0].nat_ip

}
