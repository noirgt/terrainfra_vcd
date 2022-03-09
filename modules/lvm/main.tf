terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
    }
  }
  required_version = ">= 0.13"
}

data "vcd_vm" "vm" {
  name                  = "${var.vm_name}"
}

locals {
  length_list_disks     = length(data.vcd_vm.vm.internal_disk)
  list_disk_unit_number = slice(data.vcd_vm.vm.internal_disk[*]["unit_number"], 1, local.length_list_disks)
  list_disk_size        = slice(data.vcd_vm.vm.internal_disk[*]["size_in_mb"], 1, local.length_list_disks)
  list_disk_mount       = [for disk in slice(
    data.vcd_vm.vm.internal_disk, 1, local.length_list_disks
    ) : var.lvm_scheme[disk["unit_number"]]]
}

resource "null_resource" "ansible-lvm" {
  triggers = {
    lvm_scheme_length   = length(var.lvm_scheme),
    lvm_scheme_values   = join(", ", "${values(var.lvm_scheme)}")
  }

  provisioner "local-exec" {
    command  = "NUM_DISKS=\"$num_disks\" IP=${
      data.vcd_vm.vm.network[0].ip
    } LVM=\"$disk_unit_number | $disk_size | $disk_mount\" ansible-playbook -u ${var.ssh_user} -i ansible/inventory.py ansible/lvm.yml"
    
    environment = {
      disk_unit_number = join(", ", "${local.list_disk_unit_number}")
      disk_size        = join(", ", "${local.list_disk_size}")
      disk_mount       = join(", ", "${local.list_disk_mount}")
      num_disks        = local.length_list_disks
     }
  }
}
