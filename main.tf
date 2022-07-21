provider "yandex" {
#  token     = "<OAuth>" получает из YC_TOKEN
  folder_id = var.yandex_folder_id
  zone      = var.yc_zone
}


#Установка Nginx и LetsEncrypt
#2vCPU, 2 RAM, External address (Public) и Internal address
#output "nginx_external_ip" {
#  value = "${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"
#}

########################
###   reverse proxy
########################
resource "yandex_compute_instance" "vm-1" {
  name = "runnerultra"

  resources {
    cores  = 2
    memory = 2
    core_fraction = var.fract_cpu
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
  preemptible = var.interruptable
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


###############################
###  создание сети и подсетей
################################
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = var.subnet_1
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = var.yc_zone_2
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = var.subnet_2
}

###########################
###   DNS
###########################
resource "yandex_dns_zone" "dns_zone1" {
  name        = "my-dns-zone"
  description = "desc"
  folder_id = var.yandex_folder_id

  # labels = {
  #   label1 = "label-1-value"
  # }

  zone             = var.youdomain
  public = true

}
#DNS records
resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.dns_zone1.id
  name    = join(".",["www",var.youdomain])
  type    = "A"
  ttl     = 60
  data    = ["${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"]
}

resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.dns_zone1.id
  name    = join(".",["gitlab",var.youdomain])
  type    = "A"
  ttl     = 60
  data    = ["${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.dns_zone1.id
  name    = join(".",["grafana",var.youdomain])
  type    = "A"
  ttl     = 60
  data    = ["${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"]
}

resource "yandex_dns_recordset" "prometheus" {
  zone_id = yandex_dns_zone.dns_zone1.id
  name    = join(".",["prometheus",var.youdomain])
  type    = "A"
  ttl     = 60
  data    = ["${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"]
}

resource "yandex_dns_recordset" "alertmanager" {
  zone_id = yandex_dns_zone.dns_zone1.id
  name    = join(".",["alertmanager",var.youdomain])
  type    = "A"
  ttl     = 60
  data    = ["${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"]
}

output "nginx_external_ip" {
  value = "${resource.yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"
}

output "nginx_internal_ip" {
  value = "${resource.yandex_compute_instance.vm-1.network_interface.0.ip_address}"
}

output "www_domain" {
  value = trimsuffix(yandex_dns_recordset.www.name, ".")
  
}

# output "gitlab_domain" {
#   value = yandex_dns_recordset.gitlab.name
  
# }
