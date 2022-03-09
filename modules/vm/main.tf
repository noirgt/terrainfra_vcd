terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
    }
  }
  required_version = ">= 0.13"
}

resource "vcd_vm_internal_disk" "vm-disk" {
  for_each               = var.vm_disks

  vdc                    = "${var.vcd_vdc}"
  vapp_name              = vcd_vm.vm.vapp_name
  vm_name                = "${var.vm_name}"
  size_in_mb             = trim(values(each.value)[0], "G") * 1024
  bus_type               = "paravirtual"
  bus_number             = 0
  unit_number            = each.key
  allow_vm_reboot        = true
  storage_profile        = keys(each.value)[0]

  depends_on = [
    vcd_vm.vm
  ]
}

resource "vcd_vm" "vm" {
  name                   = "${var.vm_name}"
  vdc                    = "${var.vcd_vdc}"
  catalog_name           = "${var.vm_template_catalog}"
  template_name          = "${var.vm_template}"
  cpus                   = var.vm_cpus
  memory                 = var.vm_memory * 1024

  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true

  dynamic "network" {
    for_each = var.vm_ip
    content {
      name               = keys(network.value)[0]
      type               = "org"
      ip_allocation_mode = "${var.vm_ip_allomode}"
      ip                 = values(network.value)[0]
    }
  }
}

resource "null_resource" "ssh_connection" {
  connection {
    type                 = "ssh"
    host                 = vcd_vm.vm.network[0].ip
    user                 = "${var.ssh_user}"
    password             = "${var.ssh_pass}"
    agent                = false
  }
  
  provisioner "file" {
    source               = "${var.public_ssh_key_path}"
    destination          = "/home/${var.ssh_user}/.ssh/authorized_keys"
  }

  depends_on = [
    vcd_vm.vm,
    vcd_vm_internal_disk.vm-disk
  ]
}

# Blocks for configuration with Ansible
module "lvm" {
  source                 = "../lvm"
  count                  = "${var.lvm_scheme == false ? 0 : 1}"
  
  vm_name                = vcd_vm.vm.name
  lvm_scheme             = var.lvm_scheme
  ssh_user               = var.ssh_user

  depends_on = [
    vcd_vm.vm,
    vcd_vm_internal_disk.vm-disk,
    null_resource.ssh_connection
  ]
}
