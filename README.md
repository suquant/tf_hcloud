# Hetzner cloud servers/instances module for terraform

## Key features

* Modular interface for usage in multi provider services/modules


## Interfaces

### Input variables

* count - count of hosts (default: 0)
* name - name of cluster/project/... (using in hostname generation) (default: default)
* domain - base domain (default: example.com)
* hostname_format - Hostname format: (name, number) (default: "%s-%02d")
* ssh_keys - list of ssh public keys files (default: ["~/.ssh/id_rsa.pub"])
* ssh_names - in case if you manually provide ssh names, for example if that key already presented in cloud provider
* image - OS image (default: ubuntu-16.04)
* server_type - server/istance type (default: cx11)
* datacenters - list of datacenters, every next server/instance will use next datacenter in cycle (default: ["nbg1-dc3", "fsn1-dc8", "hel1-dc2"])  
* apt_packages - extra apt packages installed before server/instance became ready (default: []) 


### Output variables

* ids - list of instance's id
* hostnames - list of instance's hostname
* public_ips - list of instance's public_ip
* private_ips - list of instance's private_ip
* ssh_names - list of ssh name attached to instance's group/module
* private_interface - private interface name (default: eth0)

## Example

```
variable "token" {}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git?ref=v1.0.0"

  count = "1"
  token = "${var.token}"
}
```
