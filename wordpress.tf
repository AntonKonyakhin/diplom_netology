resource "yandex_compute_instance" "app" {
  name = "app"
  zone = "ru-central1-b"
  resources {
    cores  = 4
    memory = 4
    core_fraction = var.fract_cpu
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = false
  }

  scheduling_policy {
    preemptible = var.interruptable
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "wordpress_internal_ip" {
    value = "${resource.yandex_compute_instance.app.network_interface.0.ip_address}"
}
