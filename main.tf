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

resource "null_resource" "change_dns_ptr" {
  count       = "${var.count}"

  provisioner "local-exec" {
    command = "${path.module}/scripts/change_dns_ptr.sh"

    environment {
      token   = "${var.token}"
      server  = "${element(hcloud_server.instance.*.id, count.index)}"
      ip      = "${element(hcloud_server.instance.*.ipv4_address, count.index)}"
      ptr     = "${element(data.template_file.hostname.*.rendered, count.index)}.${var.domain}"
    }
  }
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