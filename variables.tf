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
    filename           = "kubesolo-debian-12-generic-amd64-20250528-2126.qcow2.img"
    url                = "https://cloud.debian.org/images/cloud/bookworm/20250528-2126/debian-12-generic-amd64-20250528-2126.qcow2"
    checksum           = "790b29c10c54c926c2aaef2583f5cc9b356d0c0fb6e9884c3f33fec78b1612407c920718a827da8f65a22065479764c41812d545bae8a4ece6a49a2e8ed746ce"
    checksum_algorithm = "sha512"
    },
    {
      name               = "arm64"
      filename           = "kubesolo-debian-12-generic-arm64-20250528-2126.qcow2.img"
      url                = "https://cloud.debian.org/images/cloud/bookworm/20250528-2126/debian-12-generic-arm64-20250528-2126.qcow2"
      checksum           = "29a4aaa372f921ee77bd163359c4c321ef593f43ca524a2536e93c686a0feeb61b9c5f720d11c27c3aa4473e19b3a1d53112ee9a1395e82f8a0e35f73acda289"
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