# Variables of module "VM"
# For create VM
variable "vcd_vdc" {
  description = "Virtal DC's name of VCD"
}

variable "vm_name" {
  description = "VM's name"
}

variable "vm_template_catalog" {
  description = "Template's catalog name"
}

variable "vm_template" {
  description = "Template's name"
}

variable "vm_cpus" {
  description = "Number of CPU cores"
}

variable "vm_memory" {
  description = "Value of memory"
}

variable "vm_ip_allomode" {
  description = "Allocated mode for network"
}

variable "vm_ip" {
  description = "IP-address of installed instance"
}

variable "vm_disks" {
  description = "Count and type disks"
}

# For SSH connection to VM
variable "ssh_user" {
  description = "Username for SSH connection to VM"
}

variable "ssh_pass" {
  description = "Password for SSH connection to VM"
}

variable "public_ssh_key_path" {
  description = "Path of pulick key for SSH connection to VM"
}

# For LVM creating
variable "lvm_scheme" {
  description = "Dictionary with LVM parameters"
}
