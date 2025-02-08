terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
  service_account_key_file = "tf-service-key.json"
  folder_id = "b1g6ntej0h8v53mpsa8a"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_ed25519"
  file_permission = "0400"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/id_ed25519.pub"
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd86idv7gmqapoeiq5ld"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ipiris:${tls_private_key.ssh_key.public_key_openssh}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo docker run -d --name jmix-bookstore -p 8080:8080 jmix/jmix-bookstore"
    ]

    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
      user        = "ipiris"
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}

output "ssh_connection" {
  value = "ssh -i id_ed25519 ipiris@${yandex_compute_instance.vm-1.network_interface[0].nat_ip_address}"
}

output "web_app_url" {
  value = "http://${yandex_compute_instance.vm-1.network_interface[0].nat_ip_address}:8080"
}

