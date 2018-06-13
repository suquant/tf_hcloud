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