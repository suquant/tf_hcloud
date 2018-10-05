variable "token" {}
variable "server_type" {}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = ".."

  count = "1"
  server_type = "${var.server_type}"
}