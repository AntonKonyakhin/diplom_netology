# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gtus05hgmcr750cbi3"
}

variable "yc_zone" {
  description = "yandex cloud zone"
  type = string
  default = "ru-central1-a"
}

variable "yc_zone_2" {
  description = "yandex cloud zone 2"
  type = string
  default = "ru-central1-b"
}

variable "bucket_name" {
  description = "bucket name"
  type = string
  default = "netologybucket"
}

variable "bucket_region" {
  description = "region"
  type = string
  default = "ru-central1"
}

# id образа ubuntu 18.04
variable "image_id" {
  description = "image id"
  type = string
  default = "fd8hjvnsltkcdeqjom1n"
}

# внутренняя сеть 1
variable "subnet_1" {
  description = "subnet"
  type = tuple([string])
  default = ["192.168.10.0/24"]
  }

# внутренняя сеть 2
variable "subnet_2" {
  description = "subnet"
  type = tuple([string])
  default = ["192.168.100.0/24"]
}

# зарегестрированное доменное имя
variable "youdomain" {
  description = "domain name"
  type = string
  default = "runnerultra.ru."
}

# почта для получения сертификата
variable "email" {
  description = "letsencrypt_email"
  type =  string
  default = "a.konyakhin@gmail.com"  
}

# порт squid
variable "proxy_port" {
  description = "proxy port"
  type = string
  default = "3128"
  
}

# тип виртуальной машины: прерываемая или нет
variable "interruptable" {
  description = "type of vm"
  type = string
  default = false
}

variable "fract_cpu" {
  description = "type cpu of vm"
  type = number
  default = 100
}