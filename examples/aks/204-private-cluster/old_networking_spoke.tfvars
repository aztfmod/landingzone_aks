level = "level2"
landingzone_name = "aks_networking_spoke"

tfstates = {
  caf_foundations = {
    tfstate = "caf_foundations.tfstate"
  }
  networking = {
    tfstate = "networking_hub.tfstate"
  }
}

resource_groups = {
  aks_spoke_rg1 = {
    name   = "aks-vnet"
    region = "region1"
  }
}

vnets = {
  spoke_aks_rg1 = {
    resource_group_key = "aks_spoke_rg1"
    region             = "region1"
    vnet = {
      name          = "aks"
      address_space = ["100.64.48.0/22"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name            = "aks_nodepool_system"
        cidr            = ["100.64.48.0/24"]
        route_table_key = "default_to_firewall_rg1"
      }
      aks_nodepool_user1 = {
        name            = "aks_nodepool_user1"
        cidr            = ["100.64.49.0/24"]
        route_table_key = "default_to_firewall_rg1"
      }
      aks_nodepool_user2 = {
        name            = "aks_nodepool_user2"
        cidr            = ["100.64.50.0/24"]
        route_table_key = "default_to_firewall_rg1"
      }
      AzureBastionSubnet = {
        name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet 
        cidr    = ["100.64.51.64/27"]
        nsg_key = "azure_bastion_nsg"
      }
      private_endpoints = {
        name                                           = "private_endpoints"
        cidr                                           = ["100.64.51.0/27"]
        enforce_private_link_endpoint_network_policies = true
      }
      jumpbox = {
        name            = "jumpbox"
        cidr            = ["100.64.51.128/27"]
        route_table_key = "default_to_firewall_rg1"
      }
    }

  }
}

vnet_peerings = {
  spoke_aks_rg1_TO_hub_rg1 = {
    name = "spoke_aks_rg1_TO_hub_rg1"
    from = {
      vnet_key = "spoke_aks_rg1"
    }
    to = {
      tfstate_key = "networking_hub"
      lz_key      = "networking_hub"
      output_key  = "vnets"
      vnet_key    = "hub_rg1"
    }
    allow_virtual_network_access = true
    allow_forwarded_traffic      = false
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }

  hub_rg1_TO_spoke_aks_rg1 = {
    name = "hub_rg1_TO_spoke_aks_rg1"
    from = {
      tfstate_key = "networking_hub"
      lz_key      = "networking_hub"
      output_key  = "vnets"
      vnet_key    = "hub_rg1"
    }
    to = {
      vnet_key = "spoke_aks_rg1"
    }
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
  }

}


network_security_group_definition = {
  # This entry is applied to all subnets with no NSG defined
  empty_nsg = {
  }

  azure_bastion_nsg = {
    diagnostic_profiles = {
      nsg = {
        definition_key   = "network_security_group"
        destination_type = "storage"
        destination_key  = "all_regions"
      }
      operations = {
        name             = "operations"
        definition_key   = "network_security_group"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

    nsg = [
      {
        name                       = "bastion-in-allow",
        priority                   = "100"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "bastion-control-in-allow-443",
        priority                   = "120"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      {
        name                       = "Kerberos-password-change",
        priority                   = "121"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "4443"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      {
        name                       = "bastion-vnet-out-allow-22",
        priority                   = "103"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "bastion-vnet-out-allow-3389",
        priority                   = "101"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "bastion-azure-out-allow",
        priority                   = "120"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
      }
    ]
  }
}

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
      tfstate_key = "networking_hub"
      output_key  = "azurerm_firewalls"
      fw_key      = "fw_rg1"
      interface_index = 0
    }

    # To be set when next_hop_type = "VirtualAppliance"
    private_ip_keys = {
      azurerm_firewall = {
        
        key             = "fw_rg1"
        interface_index = 0
      }
      # virtual_machine = {
      #   key = ""
      #   nic_key = ""
      # }
    }
  }
}


bastion_hosts = {
  launchpad_host = {
    name               = "bastion"
    resource_group_key = "aks_spoke_rg1"
    vnet_key           = "spoke_aks_rg1"
    subnet_key         = "AzureBastionSubnet"
    public_ip_key      = "bastion_host_rg1"

    # you can setup up to 5 profiles
    diagnostic_profiles = {
      operations = {
        definition_key   = "bastion_host"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

  }
}

public_ip_addresses = {
  bastion_host_rg1 = {
    name                    = "bastion-pip1"
    resource_group_key      = "aks_spoke_rg1"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"

    # you can setup up to 5 key
    diagnostic_profiles = {
      bastion_host_rg1 = {
        definition_key   = "public_ip_address"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
  }
}