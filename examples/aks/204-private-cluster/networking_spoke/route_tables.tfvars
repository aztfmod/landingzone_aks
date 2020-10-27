route_tables = {
  default_to_firewall_rg1 = {
    name               = "default_to_firewall_rg1"
    resource_group_key = "aks_spoke_rg1"
  }
}

azurerm_routes = {

  default_to_firewall_rg1 = {
    name               = "0-0-0-0-through-firewall-rg1"
    resource_group_key = "aks_spoke_rg1"
    route_table_key    = "default_to_firewall_rg1"
    address_prefix     = "0.0.0.0/0"
    next_hop_type      = "VirtualAppliance"
    remote_tfstate = {
      tfstate_key     = "networking_hub"
      output_key      = "azurerm_firewalls"
      fw_key          = "fw_rg1"
      interface_index = 0
    }

    # To be set when next_hop_type = "VirtualAppliance"
    # private_ip_keys = {
    #   azurerm_firewall = {

    #     key             = "fw_rg1"
    #     interface_index = 0
    #   }
    # virtual_machine = {
    #   key = ""
    #   nic_key = ""
    # }
    # }
  }
}
