resource_groups = {
  vnet_sg = {
    name       = "vnet-sg"
    location   = "southeastasia"
    useprefix  = true
    max_length = 40
  }
  vnet_ea = {
    name       = "vnet-ea"
    location   = "eastasia"
    useprefix  = true
    max_length = 40
  }
}

vnets = {
  hub_sg = {
    resource_group_key = "vnet_sg"
    location           = "southeastasia"
    vnet = {
      name          = "hub"
      address_space = ["10.10.100.0/24"]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" #Must be called GateWaySubnet in order to host a Virtual Network Gateway
        cidr = ["10.10.100.224/27"]
      }
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet 
        cidr = ["10.10.100.192/27"]
      }
    }
    subnets = {
      Active_Directory = {
        name     = "Active_Directory"
        cidr     = ["10.10.100.0/27"]
        nsg_name = "Active_Directory_nsg"
        nsg      = []
      }
      AzureBastionSubnet = {
        name     = "AzureBastionSubnet" #Must be called AzureBastionSubnet 
        cidr     = ["10.10.100.160/27"]
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
      jumpbox = {
        name     = "jumpbox"
        cidr     = ["10.10.100.32/27"]
        nsg_name = "jumpbox_nsg"
        nsg      = []
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

  spoke_aks_sg = {
    resource_group_key = "vnet_sg"
    location           = "southeastasia"
    vnet = {
      name          = "aks"
      address_space = ["10.10.100.0/23"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name     = "aks_nodepool_system"
        cidr     = ["10.10.100.0/25"]
        nsg_name = "aks_nodepool_system_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
      aks_nodepool_system1 = {
        name     = "aks_nodepool_system1"
        cidr     = ["10.10.100.128/25"]
        nsg_name = "aks_nodepool_system1_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
      aks_nodepool_user1 = {
        name     = "aks_nodepool_user1"
        cidr     = ["10.10.101.0/25"]
        nsg_name = "aks_nodepool_user1_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
    }
  }

  hub_ea = {
    resource_group_key = "vnet_ea"
    location           = "eastasia"
    vnet = {
      name          = "hub"
      address_space = ["10.20.100.0/24"]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" #Must be called GateWaySubnet in order to host a Virtual Network Gateway
        cidr = ["10.20.100.224/27"]
      }
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet 
        cidr = ["10.20.100.192/27"]
      }
    }
    subnets = {
      Active_Directory = {
        name     = "Active_Directory"
        cidr     = ["10.20.100.0/27"]
        nsg_name = "Active_Directory_nsg"
        nsg      = []
      }
      AzureBastionSubnet = {
        name     = "AzureBastionSubnet" #Must be called AzureBastionSubnet 
        cidr     = ["10.20.100.160/27"]
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

  spoke_aks_ea = {
    resource_group_key = "vnet_ea"
    location           = "eastasia"
    vnet = {
      name          = "aks"
      address_space = ["10.20.100.0/23"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name     = "aks_nodepool_system"
        cidr     = ["10.20.100.0/25"]
        nsg_name = "aks_nodepool_system_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
      aks_nodepool_system1 = {
        name     = "aks_nodepool_system1"
        cidr     = ["10.20.100.128/25"]
        nsg_name = "aks_nodepool_system1_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
      aks_nodepool_user1 = {
        name     = "aks_nodepool_user1"
        cidr     = ["10.20.101.0/25"]
        nsg_name = "aks_nodepool_user1_nsg"
        nsg      = []
        enforce_private_link_endpoint_network_policies = true
      }
    }
  }


}

peerings = {

}

bastions = {
  southeastasia = {
    location           = "southeastasia"
    resource_group_key = "vnet_sg"
    vnet_key           = "hub_sg"
    subnet_key         = "AzureBastionSubnet"

    bastion_ip_addr_config = {
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

    bastion_config = {
      name = "bastion"
      diagnostics = {
        log = [
          #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
          ["BastionAuditLogs", true, true, 30],
        ]
        metric = [
        ]
      }
    }
  }
}