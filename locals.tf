locals {
  ssh_keys = ["${compact(concat(hcloud_ssh_key.ssh_key.*.name, var.ssh_names))}"]
}