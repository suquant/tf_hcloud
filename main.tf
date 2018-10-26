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

locals {
  ssh_keys = ["${compact(concat(hcloud_ssh_key.ssh_key.*.name, var.ssh_names))}"]
}


resource "hcloud_ssh_key" "ssh_key" {
  count = "${length(var.ssh_keys)}"

  name        = "${format("%s-%02d", var.name, (count.index + 1))}"
  public_key  = "${file(element(var.ssh_keys, count.index))}"
}


resource "hcloud_server" "instance" {
  count       = "${var.count}"

  name        = "${element(data.template_file.hostname.*.rendered, count.index)}"
  datacenter  = "${element(var.datacenters, (count.index % length(var.datacenters)))}"
  image       = "${var.image}"
  server_type = "${var.server_type}"
  ssh_keys    = ["${local.ssh_keys}"]
  user_data   = "${element(data.template_file.user_data.*.rendered, count.index)}"

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "DEBIAN_FRONTEND=noninteractive apt install -yq ${join(" ", var.apt_packages)}"
    ]
  }
}

resource "hcloud_rdns" "dns_ptrs" {
  count       = "${var.count}"

  server_id   =  "${element(hcloud_server.instance.*.id, count.index)}"
  ip_address  = "${element(hcloud_server.instance.*.ipv4_address, count.index)}"
  dns_ptr     = "${element(data.template_file.hostname.*.rendered, count.index)}.${var.domain}"
}

data "template_file" "user_data" {
  count     = "${var.count}"
  template  = "${file("${path.module}/templates/cloud_config.yaml")}"

  vars {
    domain        = "${var.domain}"
    hostname      = "${element(data.template_file.hostname.*.rendered, count.index)}"
    resolv_conf   = "${element(data.template_file.resolv_conf.*.rendered, count.index)}"
  }
}

data "template_file" "resolv_conf" {
  count     = "${var.count}"
  template  = "${file("${path.module}/templates/resolv.conf")}"

  vars {
    domain    = "${var.domain}"
    hostname  = "${element(data.template_file.hostname.*.rendered, count.index)}"
  }
}

data "template_file" "hostname" {
  count     = "${var.count}"
  template  = "$${value}"

  vars {
    value = "${format(var.hostname_format, var.name, count.index + 1)}"
  }
}


output "ids" {
  value = ["${hcloud_server.instance.*.id}"]
}

output "hostnames" {
  value = ["${hcloud_server.instance.*.name}"]
}

output "public_ips" {
  value = ["${hcloud_server.instance.*.ipv4_address}"]
}

output "private_ips" {
  value = ["${hcloud_server.instance.*.ipv4_address}"]
}

output "ssh_names" {
  value = ["${hcloud_ssh_key.ssh_key.*.name}"]
}

output "private_interface" {
  value = "eth0"
}