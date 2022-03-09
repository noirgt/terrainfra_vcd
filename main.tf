terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
    }
  }
  required_version = ">= 0.13"
}

provider "vcd" {
  user                 = "${var.vcd_user}"
  password             = "${var.vcd_pass}"
  org                  = "${var.vcd_org}"
  vdc                  = "${var.vcd_vdc}"
  url                  = "${var.vcd_url}"
  max_retry_timeout    = "${var.vcd_max_retry_timeout}"
  allow_unverified_ssl = "${var.vcd_allow_unverified_ssl}"
}

module "vm" {
  source               = "./modules/vm"
  for_each             = local.vms

  providers = { 
    vcd     = vcd
  }

  # Name and VDC
  vcd_vdc              = "${var.vcd_vdc}"
  vm_name              = each.key
 
  # OS version
  vm_template_catalog  = "${local.catalog["templates"]}"
  vm_template          = each.value["os"]

  # Hardware
  vm_cpus              =   keys(each.value["hardware"])[0]
  vm_memory            = values(each.value["hardware"])[0]

  # Network
  vm_ip_allomode       = "MANUAL"
  vm_ip                = each.value["vm_ip"]
  
  # Disks
  vm_disks             = try(each.value["vm_disks"], {})

  # SSH connection
  ssh_user             = "${var.ssh_user}"
  ssh_pass             = "${var.ssh_pass}"
  public_ssh_key_path  = "${var.public_ssh_key_path}"

  # LVM configuration
  lvm_scheme           = try(each.value["lvm"], false)
}
