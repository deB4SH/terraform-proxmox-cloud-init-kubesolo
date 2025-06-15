resource "proxmox_virtual_environment_file" "cloud-init-kubesolo" {

  for_each     = { for each in var.vm : each.name => each }
  node_name    = coalesce(each.value.node, var.pve_default_node)
  content_type = "snippets"
  datastore_id = var.pve_default_snippet_datastore_id

  source_raw {
    data = templatefile("${path.module}/templates/vm.yaml.tftpl", {
      #defaults
      hostname      = each.value.name
      user          = var.vm_user
      user_password = var.vm_user_password
      user_pub_key  = var.vm_user_public_key
      timezone      = var.pve_default_timezone
      arch          = var.vm_worker_arch
      #apt related
      debian_primary_mirror          = var.debian_primary_mirror
      debian_primary_security_mirror = var.debian_primary_security_mirror
      #kubernetes related
      ip                          = element(split("/", each.value.ip), 0)
      dns_server = var.dns_configuration.servers
      dns_domain = var.dns_configuration.domain

    })
    file_name = format("%s-%s.yaml", "${var.vm_worker_startid + each.value.id_offset}", each.value.name)
  }
}