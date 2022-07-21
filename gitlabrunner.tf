resource "yandex_compute_instance" "gitlab" {
  name = "gitlab"
  zone = "ru-central1-b"

  resources {
    cores  = 4
    memory = 4
    core_fraction = var.fract_cpu
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size = 10
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

resource "yandex_compute_instance" "runner" {
  name = "runner"
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

output "gitlab_internal_ip" {
  value = "${resource.yandex_compute_instance.gitlab.network_interface.0.ip_address}"
}

output "runner_internal_ip" {
  value = "${resource.yandex_compute_instance.runner.network_interface.0.ip_address}"
}
