locals {
  net  = {
    "prod": data.vcd_network_routed.prod.name,
    "test": data.vcd_network_routed.test.name,
    "srvc": data.vcd_network_routed.service.name,
    "org" : data.vcd_network_routed.org.name
  }
}

# Data of all VCD's networks
data "vcd_network_routed" "prod" {
  vdc  = var.vcd_vdc
  name = "example_prod"
}

data "vcd_network_routed" "test" {
  vdc  = var.vcd_vdc
  name = "example_test"
}

data "vcd_network_routed" "service" {
  vdc  = var.vcd_vdc
  name = "example_service"
}

data "vcd_network_routed" "org" {
  vdc  = var.vcd_vdc
  name = "example-Org-Net01"
}
