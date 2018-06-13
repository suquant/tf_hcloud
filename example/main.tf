variable "token" {}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = ".."

  count = "1"
  token = "${var.token}"
}