resource "local_file" "ctrl-ip" {
  depends_on   = [proxmox_virtual_environment_vm.vm-worker]
  for_each = {for each in var.vm: each.name => each}

  content         = proxmox_virtual_environment_vm.vm-worker[each.key].ipv4_addresses[1][0]
  filename        = "output/ctrl-ip-${each.key}.txt"
  file_permission = "0644"
}

module "kube-config" {
  depends_on   = [proxmox_virtual_environment_vm.vm-worker]
  for_each = {for each in var.vm: each.name => each}

  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o UserKnownHostsFile=/tmp/known_host_${each.key} -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.ctrl-ip[each.key].content} cat /tmp/admin.kubeconfig"
}

resource "local_file" "kube-config" {
  for_each = {for each in var.vm: each.name => each}

  content         = module.kube-config[each.key].stdout
  filename        = "output/config-${each.key}"
  file_permission = "0600"
}