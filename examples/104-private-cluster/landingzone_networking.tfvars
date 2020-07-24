resource_groups = {
  vnet_eus = {
    name       = "vnet-eus"
    location   = "eastus"
    useprefix  = true
    max_length = 40
  }
  vnet_wus = {
    name       = "vnet-wus"
    location   = "westus"
    useprefix  = true
    max_length = 40
  }
}

vnets = {
  hub_eus = {
    resource_group_key = "vnet_eus"
    location           = "eastus"
    vnet = {
      name          = "hub"
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
      Active_Directory = {
        name     = "Active_Directory"
        cidr     = ["100.64.102.0/27"]
        nsg_name = "Active_Directory_nsg"
        nsg      = []
      }
      AzureBastionSubnet = {
        name     = "AzureBastionSubnet" #Must be called AzureBastionSubnet 
        cidr     = ["100.64.103.0/27"]
        nsg_name = "AzureBastionSubnet_nsg"
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
    # Override the default var.diagnostics.vnet
    diagnostics = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
        ["VMProtectionAlerts", true, true, 60],
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]                 
        ["AllMetrics", true, true, 60],
      ]
    }
  }

  spoke_aks_eus = {
    resource_group_key = "vnet_eus"
    location           = "eastus"
    vnet = {
      name          = "aks"
      address_space = ["100.64.48.0/22"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name     = "aks_nodepool_system"
        cidr     = ["100.64.48.0/24"]
        nsg_name = "aks_nodepool_system_nsg"
        nsg      = []
      }
      aks_nodepool_user1 = {
        name     = "aks_nodepool_user1"
        cidr     = ["100.64.49.0/24"]
        nsg_name = "aks_nodepool_user1_nsg"
        nsg      = []
      }
      aks_nodepool_user2 = {
        name     = "aks_nodepool_user2"
        cidr     = ["100.64.50.0/24"]
        nsg_name = "aks_nodepool_user2_nsg"
        nsg      = []
      }
    }
  }
}

peerings = {
  hub_eus_TO_spoke_aks_eus = {
    from_key                     = "hub_eus"
    to_key                       = "spoke_aks_eus"
    name                         = "hub_eus_TO_spoke_aks_eus"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = false
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }

  spoke_aks_eus_TO_hub_eus = {
    from_key                     = "spoke_aks_eus"
    to_key                       = "hub_eus"
    name                         = "spoke_aks_eus_TO_hub_eus"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = false
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
}

firewalls = {
  # Southeastasia firewall (do not change the key when created)
  eastus = {
    location           = "eastus"
    resource_group_key = "vnet_eus"
    vnet_key           = "hub_eus"

    # Settings for the public IP address to be used for Azure Firewall 
    # Must be standard and static for 
    firewall_ip_addr_config = {
      ip_name           = "firewall"
      allocation_method = "Static"
      sku               = "Standard" #defaults to Basic
      ip_version        = "IPv4"     #defaults to IP4, Only dynamic for IPv6, Supported arguments are IPv4 or IPv6, NOT Both
      diagnostics = {
        log = [
          #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
          ["DDoSProtectionNotifications", true, true, 30],
          ["DDoSMitigationFlowLogs", true, true, 30],
          ["DDoSMitigationReports", true, true, 30],
        ]
        metric = [
          ["AllMetrics", true, true, 30],
        ]
      }
    }

    # Settings for the Azure Firewall settings
    az_fw_config = {
      name = "azfw"
      diagnostics = {
        log = [
          #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
          ["AzureFirewallApplicationRule", true, true, 30],
          ["AzureFirewallNetworkRule", true, true, 30],
        ]
        metric = [
          ["AllMetrics", true, true, 30],
        ]
      }
      network_rules = {
        
      }
      application_rules = {
        
      }
    }
  }
}
