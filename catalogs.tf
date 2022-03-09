# Template catalog
locals {
  catalog = {
    "templates": data.vcd_catalog.templates.name
  }
}

# Catalogs
data "vcd_catalog" "templates" {
  org  = var.vcd_org
  name = "Terraform templates"
}
