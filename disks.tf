# Disks (Storage profiles)
locals {
  disk  = {
    "ssd": data.vcd_storage_profile.ssd.name,
    "hdd": data.vcd_storage_profile.hdd.name
  }
}
