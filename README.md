Terraform Proxmox Cloud Init Kubesolo
===

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

This module sets up a kubesolo installation on a proxmox hypervisor using cloud-init for automation. It provisions the necessary virtual machine, deploys the kubesolo application , and provides you easy access towards the kubeconfig. The module assumes you have a proxmox server with an active PVE install. It does not require a prepared image and just uses the default debian cloud init image.

This setup is mainly focused around testing and is definitly not suited for a production workload. Please have a look towards the awesome project by portainer: https://github.com/portainer/kubesolo

## Module Versions
This module comes in different flavours as we progress in different endeavors. A upcomming list should help you to determine which release may be applicable for you.

* dev
  * Current development branch which may be highly unstable and is definitly not production ready
* main
  * Reflects the latest changes on this module and follows is the father branch of every release

### Development Targets
This module is currently only maintained on the latest release. Changes on the currently dev or main version are not backported to older releases. Feel free to contribute and backport some things to older versions! A contribution is always welcome!

## Setup Guide

The setup guide may change according to your desired version. Please refer to each branchs setup guide to view the actual setup documentation. This guide is subject to change when changes occure on the development or main branch. 

### Initial Configuration
Start your terraform setup with a generic `main.tf` and import the required providers.
```tf
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}
```
As next code snippet we need to configure our proxmox provider. It helps to use aliases for easier references on multiple enviroments.

```tf
provider "proxmox" {
  alias    = "YOUR_PVE_HOSTNAME"
  endpoint = var.pve_node_HOSTNAME.endpoint
  insecure = var.pve_node_HOSTNAME.insecure

  username = var.pve_username
  password = var.pve_password

  #api_token = var.pve_auth.api_token
  #ssh {
  #  agent    = true
  #  username = var.pve_auth.username
  #}

  tmp_dir = "/var/tmp" #feel free to change this to a directory you desire
}
```
The commented parts describe a different communication way between terraform and proxmox. Per default most users seem to enjoy connect with a username and password. Others a connection via ssh. Please refer to the *Authentication* documentation within the offical guide found here: https://registry.terraform.io/providers/bpg/proxmox/latest/docs#authentication

As next step create a `variables.tf` and paste the following content into it.
```tf
/**
* PVE Node Configuration
*/
variable "pve_node_HOSTNAME" {
  description = "Proxmox server configuration for pve node"
  type = object({
    node_name = string
    endpoint  = string
    insecure  = bool
  })
}

variable "pve_auth" {
  description = "Auth configuration for pve node"
  type = object({
    username  = string
    api_token = string
  })
  sensitive = true
}
```
Please adjust the hostnames accordingly to your infrastructure and replace all references in your `main.tf`.

As next big step we need to add the kubernetes module to the `main.tf` and configure it. The following snippet is a just a possible configuration. Please review it!
```tf
module "kubesolo" {
  source = "git::https://github.com/deB4SH/terraform-proxmox-cloud-init-kubesolo.git?ref=main"

  providers = {
    proxmox = proxmox.HOSTNAME
  }

  pve_default_node = "HOSTNAME"
  pve_network_default_gateway = "10.0.0.1"

  dns_configuration = {
    domain = "."
    servers = ["10.0.0.100"]
  }
  # Images
  os_images_datastore_id = "local"
  # User Configuration
  vm_user = var.vm_user
  vm_user_password = var.vm_user_password
  vm_user_public_key = var.vm_user_pub_key

  vm = [
    {
      node = "HOSTNAME"
      name = "kubesolo-1"
      id_offset = 0
      ip = "10.0.0.200/24"
      vm_memory_count = 1024
      vm_cpu_count = 1
    }
  ]

}
```
This snippet describes a pretty minimalistic setup of one vm with kubesolo deployed.

The module is derived from my mainline repository found here: https://github.com/deB4SH/terraform-proxmox-cloud-init-kubernetes
It is quite flexible and allows fallback configuration. A complete variable overview could be obtained when reviewing the default variables here: https://github.com/deB4SH/terraform-proxmox-cloud-init-kubesolo/blob/main/variables.tf

As closing words I would like to give you some things to consider:
* It is advised to provide a debian apt cache server in your environment when working and debugging with this setup. 
* Put variables also in the variables.tf like vm_user vm_password and other parts

---

[contributors-shield]: https://img.shields.io/github/contributors/deb4sh/terraform-proxmox-cloud-init-kubesolo.svg?style=for-the-badge
[contributors-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubesolo/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/deb4sh/terraform-proxmox-cloud-init-kubesolo.svg?style=for-the-badge
[forks-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubesolo/network/members
[stars-shield]: https://img.shields.io/github/stars/deb4sh/terraform-proxmox-cloud-init-kubesolo.svg?style=for-the-badge
[stars-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubesolo/stargazers
[issues-shield]: https://img.shields.io/github/issues/deb4sh/terraform-proxmox-cloud-init-kubesolo.svg?style=for-the-badge
[issues-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubesolo/issues
[license-shield]: https://img.shields.io/github/license/deb4sh/terraform-proxmox-cloud-init-kubesolo.svg?style=for-the-badge
[license-url]: https://github.com/deb4sh/terraform-proxmox-cloud-init-kubesolo/blob/main/LICENSE.txt