tags       = {}
convention = "cafrandom"
clusters = {}

jumpboxes = {
  ubuntu = {
    name = "ubuntujumpbox"
    resource_group_name = "jumpbox"
    location = "southeastasia"
    os = "Linux"
    vnet_key           = "hub_sg"
    subnet_key         = "Jumpbox"
    storage_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
    vm_size = "Standard_DS1_v2"
    os_profile = {
        admin_username = "testadmin"
        admin_password = "Ab123456789!"
    }
    storage_os_disk = {
      name              = "ubuntuosdisk1"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
      disk_size_gb      = "128"
    }
  }
}