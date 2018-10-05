variable "count" {
  default = 0
}

variable "name" {
  default = "default"
}

variable "domain" {
  default = "example.com"
}

variable "hostname_format" {
  description = "Hostname format: (name, number)"
  default     = "%s-%02d"
}

variable "ssh_keys" {
  type    = "list"
  default = ["~/.ssh/id_rsa.pub"]
}

variable "ssh_names" {
  type    = "list"
  default = []
}

variable "image" {
  default = "ubuntu-16.04"
}

variable "server_type" {
  default = "cx11"
}

variable "datacenters" {
  type = "list"
  default = ["nbg1-dc3", "fsn1-dc8", "hel1-dc2"]
}

variable "apt_packages" {
  type    = "list"
  default = []
}