level            = "level2"
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


