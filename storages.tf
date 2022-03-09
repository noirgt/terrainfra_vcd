# Storage profiles
data "vcd_storage_profile" "ssd" {
  vdc  = data.vcd_org_vdc.dp.name
  name = "SSD_DP Storage Policy"
}

data "vcd_storage_profile" "hdd" {
  vdc  = data.vcd_org_vdc.dp.name
  name = "NonSSD_DP Storage Policy"
}
