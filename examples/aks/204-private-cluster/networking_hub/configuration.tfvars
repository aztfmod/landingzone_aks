level = "level2"

landingzone_name = "networking_hub"

tfstates = {
  caf_foundations = {
    tfstate = "caf_foundations.tfstate"
  }
  networking = {
    tfstate = "caf_foundations.tfstate"
  }
}

resource_groups = {
  vnet_hub_rg1 = {
    name   = "vnet-hub-rg1"
    region = "region1"
  }
}

vnets = {
  hub_rg1 = {
    resource_group_key = "vnet_hub_rg1"
    region             = "region1"
    vnet = {
      name          = "hub-rg1"
      address_space = ["100.64.100.0/22"]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" #Must be called GateWaySubnet in order to host a Virtual Network Gateway
        cidr = ["100.64.100.0/27"]
      }
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet
        cidr = ["100.64.101.0/26"]
      }
    }
    subnets = {
      AzureBastionSubnet = {
        name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet
        cidr    = ["100.64.101.64/26"]
        nsg_key = "azure_bastion_nsg"
      }
      jumpbox = {
        name    = "jumpbox"
        cidr    = ["100.64.102.0/27"]
        nsg_key = "jumpbox"
      }
      private_endpoints = {
        name                                           = "private_endpoints"
        cidr                                           = ["100.64.103.128/25"]
        enforce_private_link_endpoint_network_policies = true
      }
    }
  }
}