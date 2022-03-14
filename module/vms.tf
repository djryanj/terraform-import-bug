resource "azurerm_network_interface" "this" {
  count = length(var.interfaces)

  name                = var.interfaces[count.index].name
  location            = "westus2"
  resource_group_name = var.resource_group_name

  dynamic "ip_configuration" {
    for_each = toset(["primary" /*, "secondary-1"*/])
    content {
      name                          = ip_configuration.value
      subnet_id                     = var.interfaces[count.index].subnet_id
      private_ip_address_allocation = try(var.interfaces[count.index].private_ip_address, null) != null ? "static" : "dynamic"
      private_ip_address            = try(var.interfaces[count.index].private_ip_address, null)
      public_ip_address_id          = try(var.interfaces[count.index].public_ip_address_id, null)
    }
  }
}

resource "azurerm_virtual_machine" "this" {
  name                         = var.name
  location                     = "westus2"
  resource_group_name          = var.resource_group_name
  vm_size                      = "Standard_B2s"
  primary_network_interface_id = azurerm_network_interface.this[0].id

  network_interface_ids = [for k, v in azurerm_network_interface.this : v.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    create_option     = "FromImage"
    name              = "${var.name}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = var.name
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
