resource "azurecaf_naming_convention" "rg" {
  name          = var.bastion_vm.resource_group_name
  prefix        = var.prefix
  resource_type = "azurerm_resource_group"
  convention    = var.convention
}

resource "azurecaf_naming_convention" "nic" {
    convention      = "cafrandom"
    name            = "${var.bastion_vm.name}_nic"
    prefix          = var.prefix
    resource_type   = "nic"
}

resource "azurerm_resource_group" "vm_rg" {
  name     = azurecaf_naming_convention.rg.result
  location = var.bastion_vm.location
  tags     = var.tags
}

resource "azurerm_network_interface" "vm_nic" {
  name                = azurecaf_naming_convention.nic.result
  location            = var.bastion_vm.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "linux_nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

module "caf-vm" {
  source  = "aztfmod/caf-vm/azurerm"
  version = "0.1.0"
  
  prefix                        = var.prefix
  convention                    = var.convention
  name                          = var.bastion_vm.name
  resource_group_name           = azurerm_resource_group.vm_rg.name
  location                      = var.bastion_vm.location 
  tags                          = var.tags
  network_interface_ids         = [azurerm_network_interface.vm_nic.id]
  primary_network_interface_id  = azurerm_network_interface.vm_nic.id
  os                            = var.bastion_vm.os
  os_profile                    = var.bastion_vm.os_profile
  storage_image_reference       = var.bastion_vm.storage_image_reference
  vm_size                       = var.bastion_vm.vm_size
  storage_os_disk               = var.bastion_vm.storage_os_disk
}
