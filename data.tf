data "azurerm_resource_group" "this" {
  name = "rg-WestUS2"
}

data "azurerm_virtual_network" "this" {
  name                = "vnet-wus2-servers"
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_subnet" "this" {
  name                 = "private"
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = data.azurerm_resource_group.this.name
}
