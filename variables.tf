# Provider's variables
variable "vcd_user" {
  description = "Login of VCD"
}

variable "vcd_pass" {
  description = "Password of VCD"
}

variable "vcd_org" {
  description = "Organization's name of VCD"
}

variable "vcd_vdc" {
  description = "Virtal DC's name of VCD"
}

variable "vcd_url" {
  description = "URL of VCD"
}

variable "vcd_max_retry_timeout" {
  description = "Maximum timeout for interacting with resources"
}

variable "vcd_allow_unverified_ssl" {
  description = "Allowing the use of an unverified certificate"
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