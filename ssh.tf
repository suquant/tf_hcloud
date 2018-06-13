resource "hcloud_ssh_key" "ssh_key" {
  count = "${length(var.ssh_keys)}"

  name        = "${format("%s-%02d", var.name, (count.index + 1))}"
  public_key  = "${file(element(var.ssh_keys, count.index))}"
}
