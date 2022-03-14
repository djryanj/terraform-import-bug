locals {
  vms = {
    "vm1" = {
      private_ip_address = "10.0.1.20"
    }
    "vm2" = {
      private_ip_address = "10.0.1.21"
    }
  }
}

resource "azurerm_resource_group" "vms" {
  name     = "rg-import-bug-test"
  location = "westus2"
}

# resource "azurerm_public_ip" "this" {
#   for_each = local.vms
#   name                = "${each.key}-pip"
#   location            = "westus2"
#   resource_group_name = azurerm_resource_group.vms.name
# }

module "vms" {
  source = "./module"

  for_each = local.vms

  name                = each.key
  resource_group_name = azurerm_resource_group.vms.name

  interfaces = [
    {
      name      = "${each.key}-nic"
      subnet_id = data.azurerm_subnet.this.id
      #   public_ip_address_id = azurerm_public_ip.this[each.key].id
      private_ip_address = each.value.private_ip_address
    }
  ]
}
