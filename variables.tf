/**
* Proxmox related configuration.
*/
variable "pve_default_node" {
  type        = string
  description = "Default Node to use for proxmox interactions"
  default     = "pve"
}

variable "pve_default_datastore_id" {
  type        = string
  description = "Default datastore to use"
  default     = "local-lvm"
}

variable "pve_default_snippet_datastore_id" {
  type        = string
  description = "Default datastore to use"
  default     = "local"
}

variable "pve_default_timezone" {
  type        = string
  description = "Timezone to use for vms"
  default     = "Europe/Berlin"
}

variable "pve_network_default_gateway" {
  type        = string
  description = "Default gateway for each vm."
}

variable "dns_configuration" {
  description = "DNS config for VMs"
  type = object({
    domain  = string
    servers = list(string)
  })
}

/**
* User Configuration in VM
*/
variable "vm_user" {
  type        = string
  sensitive   = true
  description = "User name to use for vm access."
}

variable "vm_user_password" {
  type        = string
  sensitive   = true
  description = "User password to set automatically. Generate a sha256sum obfuscated password."
}

variable "vm_user_public_key" {
  type        = string
  description = "Public key for user account to use"
}

/**
* Debian related configuration
*/
variable "debian_primary_mirror" {
  type        = string
  default     = "https://deb.debian.org/debian"
  description = "Default mirror to use in cloud init configuration for pulling packages."
}

variable "debian_primary_security_mirror" {
  type        = string
  default     = "http://security.debian.org/debian-security/"
  description = "Default security mirror to use in cloud init configuration for pulling packages."
}

/**
* OS Image configuration to use in kubernetes deployments.
* Defaults are just a example pick. Please update accordingly.
* It is adviced to use a network attached storage as datastore to provide image to all nodes in proxmox cluster.
*/
variable "os_images" {
  type = list(object({
    name               = string
    filename           = string
    url                = string
    checksum           = string
    checksum_algorithm = string
  }))
  default = [{
    name               = "amd64"
    filename           = "generic_alpine-3.22.0-x86_64-uefi-cloudinit-r0.img"
    url                = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.0-x86_64-uefi-cloudinit-r0.qcow2"
    checksum           = "0f9626a2388450fc957ecca55b655dc7d2605d723ba3d64dc2ae1d5d8efefcdbf5e056ebb88861e3a563dd9d4036566df081955d37e68072569022d831b56481"
    checksum_algorithm = "sha512"
    },
    {
      name               = "arm64"
      filename           = "generic_alpine-3.22.0-aarch64-uefi-cloudinit-r0.qcow2.img"
      url                = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.0-aarch64-uefi-cloudinit-r0.qcow2"
      checksum           = "11c74ac1870e8b4f7611572a2ba87366de7fd99b0e39a2555e6dc9ebc164c5619093bcd2a56ba9080c79695be851f2b159c41f4beb26382bb6fafd0750b646ab"
      checksum_algorithm = "sha512"
    }
  ]
}

variable "os_images_datastore_id" {
  type        = string
  nullable    = true
  description = "Datastore to use for images."
}

variable "always_pull_os_images" {
  type        = bool
  default     = true
  description = "Always pull os images from url. This is useful for testing purposes."
}

/**
* VM Configuration
*/
variable "vm_worker_tags" {
  description = "VM tags for proxmox."
  type = object({
    tags = list(string)
  })
  default = {
    tags = ["kubernetes", "kubesolo"]
  }
}

variable "vm_worker_description" {
  type        = string
  default     = "A database as kubernetes backend used by kine."
  description = "Description for vm in proxmox."
}

variable "vm_worker_startid" {
  type        = number
  default     = 11000
  description = "Starting number for control plane vm ids."
}

variable "vm_worker_cpu" {
  type        = number
  default     = 2
  description = "Amount of cores cpu to allocate"
}

variable "vm_worker_memory" {
  type        = number
  default     = 2048
  description = "Amount of memory to allocate"
}

variable "vm_worker_arch" {
  type        = string
  default     = "amd64"
  description = "System architecture to use"
}

variable "vm_worker_disk_size" {
  type        = number
  default     = 32
  description = "Size of control plane vm disk."
}

variable "vm" {
  type = list(object({
    #general configuration
    node      = optional(string)
    name      = string
    id_offset = number
    #vm configuration
    vm_cpu_count      = optional(number)
    vm_memory_count   = optional(number)
    os_image_type     = optional(string)
    disk_datastore_id = optional(string)
    #network
    ip      = string
    gateway = optional(string)
  }))
  description = "Kubernetes Worker definition for cluster"
}