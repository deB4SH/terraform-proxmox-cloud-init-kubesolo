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
    filename           = "kubernetes-debian-12-generic-amd64-20250115-1993.img"
    url                = "https://cloud.debian.org/images/cloud/bookworm/20250115-1993/debian-12-generic-amd64-20250115-1993.qcow2"
    checksum           = "75db35c328863c6c84cb48c1fe1d7975407af637b272cfb8c87ac0cc0e7e89c8a1cc840c2d6d82794b53051a1131d233091c4f4d5790557a8540f0dc9fc4f631"
    checksum_algorithm = "sha512"
    },
    {
      name               = "arm64"
      filename           = "kubernetes-debian-12-generic-arm64-20250115-1993.img"
      url                = "https://cloud.debian.org/images/cloud/bookworm/20250115-1993/debian-12-generic-arm64-20250115-1993.qcow2"
      checksum           = "edab065c95a5b7e117327739f7c9326ea72e3307f16d62d3a214347ab7b86c9d44e430169d7835fd4ec07f93ef54fa5c1654418d2ee1f305384f03186bdd0010"
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