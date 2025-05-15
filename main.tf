terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.77.0"
    }
  }
}

provider "ibm" {
  region = var.region
}

# SSH key
resource "ibm_is_ssh_key" "n8n_key" {
  name       = "n8n-key"
  public_key = var.ssh_public_key
}

# VPC
resource "ibm_is_vpc" "n8n_vpc" {
  name = "n8n-vpc"
}

# Subnet
resource "ibm_is_subnet" "n8n_subnet" {
  name                     = "n8n-subnet"
  vpc                      = ibm_is_vpc.n8n_vpc.id
  zone                     = var.zone
  ipv4_cidr_block          = "10.240.0.0/24"
  total_ipv4_address_count = 256
}

# Virtual Server
resource "ibm_is_instance" "n8n_instance" {
  name   = "n8n-instance"
  image  = data.ibm_is_image.ubuntu.id
  profile = "bx2-8x32"
  zone    = var.zone
  vpc     = ibm_is_vpc.n8n_vpc.id

  primary_network_interface {
    subnet = ibm_is_subnet.n8n_subnet.id
  }

  keys = [ibm_is_ssh_key.n8n_key.id]
}

# Floating IP
resource "ibm_is_floating_ip" "n8n_fip" {
  name   = "n8n-fip"
  target = ibm_is_instance.n8n_instance.primary_network_interface[0].id
}

# Get Ubuntu Image
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

# Remote installation of Docker and n8n
resource "null_resource" "install_n8n" {
  depends_on = [ibm_is_instance.n8n_instance, ibm_is_floating_ip.n8n_fip]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.ssh_private_key
    host        = ibm_is_floating_ip.n8n_fip.address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io docker-compose",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ~/n8n",
      "cat <<EOF > ~/n8n/docker-compose.yml
version: '3'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - '5678:5678'
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${var.n8n_user}
      - N8N_BASIC_AUTH_PASSWORD=${var.n8n_pass}
    volumes:
      - ~/.n8n:/home/node/.n8n
EOF",
      "cd ~/n8n && docker-compose up -d"
    ]
  }
}
